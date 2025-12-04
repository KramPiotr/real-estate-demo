# Archetypes Pipeline - Comprehensive Behavioral Feature Extraction

## Overview

The Archetypes pipeline performs comprehensive behavioral feature extraction from sales call transcripts using a detailed taxonomy-based analysis. Unlike the ENRO pipeline which focuses on specific closing behaviors, this pipeline evaluates ALL behavioral features defined in a taxonomy against each transcript.

It's designed for university-specific analysis (e.g., Monash, SOL, Federation) and uses a 2-step process.

---

## Pipeline Flow Diagram

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                           ARCHETYPES PIPELINE - 2 STEPS                              │
└─────────────────────────────────────────────────────────────────────────────────────┘

Step 1: UNIVERSITY TRANSCRIPT FILTERING (Python)
┌────────────────────────────────────────────────────────────────────────────────────┐
│  INPUT:                                                                             │
│  ├── S3 transcripts: s3://sentiment-ai-mab/transcripts/{date-range}                │
│  └── CSV metadata: precomputed/{start_date}_{end_date}.csv                         │
│                                                                                     │
│  PROCESS: oes-create-university-transcripts                                         │
│  ├── Downloads all transcripts from S3 (if not cached locally)                     │
│  ├── Reads CSV to get teamName for each contactId                                  │
│  ├── Filters transcripts where teamName matches university                         │
│  │   └── e.g., "Monash Sales" → Monash transcripts                                │
│  ├── Copies matching transcripts to university-specific directory                  │
│  └── Uploads filtered directory back to S3                                         │
│                                                                                     │
│  OUTPUT: University-filtered transcripts                                            │
│  ├── LOCAL: transcripts/weekly-analysis-{date}-{uni_code}/                         │
│  │   ├── inbound/                                                                  │
│  │   └── outbound/                                                                 │
│  └── S3: s3://sentiment-ai-mab/transcripts/{date}-{uni_code}                       │
│                                                                                     │
│  SUPPORTED UNIVERSITIES:                                                            │
│  ├── Monash (code: monash, team: "Monash Sales")                                   │
│  ├── SOL (code: sol, team: "SOL Sales")                                            │
│  ├── Federation (code: federation, team: "Federation Sales")                       │
│  ├── QUT (code: qut, team: "QUT Sales")                                            │
│  └── WSU (code: wsu, team: "WSU Sales")                                            │
└────────────────────────────────────────────────────────────────────────────────────┘
                                        │
                                        ▼
Step 2: COMPREHENSIVE BEHAVIORAL FEATURE EXTRACTION
┌────────────────────────────────────────────────────────────────────────────────────┐
│  INPUT:                                                                             │
│  ├── University transcripts: {date}-{uni_code} (from Step 1)                       │
│  └── Feature taxonomy: andre-taxonomy-feature-4-new                                │
│      ├── emotion1-taxonomy.txt (20KB - detailed emotion taxonomy)                  │
│      └── emotion2-taxonomy.txt (12KB - emotion taxonomy part 2)                    │
│                                                                                     │
│  PROCESS: multi-agent-batch                                                         │
│  ├── Config: andre-taxonomy-production-2                                           │
│  ├── Input catalog: andre-taxonomy-feature-4-new (taxonomy files)                  │
│  │                                                                                 │
│  ├── TWO-STAGE ARCHITECTURE:                                                       │
│  │   ├── Node 1 "category": 3 Azure LLM nodes (independent)                        │
│  │   │   └── Each evaluates ALL features in taxonomy                               │
│  │   │   └── Outputs: verdict, likelihood, intensity, score, confidence            │
│  │   │                                                                             │
│  │   └── Node 2 "aggregation": 1 Azure LLM node                                    │
│  │       └── Synthesizes 3 node outputs                                            │
│  │       └── Adds analyst_count (how many nodes agreed)                            │
│  │                                                                                 │
│  └── Evaluates EVERY feature in taxonomy systematically                            │
│                                                                                     │
│  OUTPUT: Comprehensive feature evaluations                                          │
│  └── partial_results/andre-taxonomy-production-2__week-{N}-{uni_code}/             │
└────────────────────────────────────────────────────────────────────────────────────┘
```

---

## Step-by-Step Details

### Step 1: Create University Transcripts (Python)

**Script:** `1-create-university-transcripts.sh`
**Entry Point:** `oes-create-university-transcripts`
**Python File:** `archetypes/create_university_transcript_directory.py`

**Purpose:** Filter transcripts by university team to enable university-specific analysis.

**Command:**
```bash
uv run oes-create-university-transcripts \
    --university Monash \
    --start-date {{START_DATE}} \
    --upload-s3
```

**Key Operations:**

1. **S3 Download** (with caching):
```python
downloaded, failed, skipped = batch_download_from_s3(
    bucket=args.s3_bucket,
    s3_prefix=s3_prefix,
    local_dir=input_dir,
    file_pattern=".json",
    skip_existing=True,  # Skip if already cached locally
)
```

2. **CSV-Based Filtering:**
```python
# Filter for university calls using teamName column
uni_calls = df[df['teamName'] == team_name]
uni_contact_ids = set(uni_calls['contactId'].astype(str))

# Match transcripts by contactId prefix in filename
for file_path in transcript_files:
    contact_id = filename.split('_')[0]
    if contact_id in uni_contact_ids:
        files_to_copy.append(file_path)
```

3. **Directory Structure Preservation:**
- Maintains inbound/outbound subdirectory structure
- Copies only matching transcripts

**University Configuration:**
```python
# From config/universities.json
UNIVERSITIES = {
    "monash": {"name": "Monash", "team_name": "Monash Sales", "enabled": True},
    "sol": {"name": "SOL", "team_name": "SOL Sales", "enabled": True},
    "federation": {"name": "Federation", "team_name": "Federation Sales", "enabled": True},
    "qut": {"name": "QUT", "team_name": "QUT Sales", "enabled": True},
    "wsu": {"name": "WSU", "team_name": "WSU Sales", "enabled": True},
}
```

---

### Step 2: Feature Extraction

**Script:** `2-extract-features.sh`

**Purpose:** Perform comprehensive behavioral feature analysis against a detailed taxonomy.

**Command:**
```bash
uv run multi-agent-batch \
    -c andre-taxonomy-production-2 \
    -sm s3 \
    -t "{{START_DATE}}-{{END_DATE}}-monash" \
    -f "over-2-mins" \
    -e east-us \
    -l gemini \
    -ss "{{WEEK_ID}}-monash" \
    -ic "andre-taxonomy-feature-4-new" \
    -s -p
```

**Key Difference from ENRO:** Uses `-ic` (input catalog) instead of `-pi` (prompt input)
- Input catalog loads a folder of taxonomy files
- Each taxonomy file is passed as context to the LLM

**Config:** `andre-taxonomy-production-2.json`

```json
{
  "input_catalog": {
    "name": "feature",
    "location": "andre-taxonomy-feature-4-new",
    "types": ["taxonomy"]
  },
  "nodes": [
    {
      "name": "category",
      "inputs": ["feature", "transcript"],
      "models": [{"provider": "azure"}, {"provider": "azure"}, {"provider": "azure"}]
    },
    {
      "name": "aggregation",
      "inputs": ["feature", "transcript", "category"],
      "models": [{"provider": "azure"}]
    }
  ]
}
```

---

## Taxonomy Structure

### Input Catalog: `andre-taxonomy-feature-4-new`

Contains comprehensive behavioral taxonomies:

| File | Size | Content |
|------|------|---------|
| `emotion1-taxonomy.txt` | 20KB | Detailed emotion/sentiment taxonomy (Part 1) |
| `emotion2-taxonomy.txt` | 12KB | Emotion taxonomy (Part 2) |

### Taxonomy File Format

Each taxonomy file is hierarchically organized:

```
Main Artifacts (e.g., 1.X.x, 2.X.x, 3.X.x, 4.X.x, 5.X.x)
├── Main Categories (e.g., 1.A, 1.B, 1.C)
│   └── Specific Features (e.g., 1.A.i, 1.A.ii, 1.A.iii)
```

Each feature definition includes:
1. **Definition** - Clear description of the behavioral pattern
2. **Checklist Conditions** - 2-4 specific, observable criteria
3. **Guiding Principles** - Contextual considerations
4. **Examples** - Illustrative evidence patterns

### Other Available Taxonomies

The S3 bucket contains 9 taxonomy collections with 71 total files:

| Collection | Files | Focus |
|------------|-------|-------|
| `andre-taxonomy` | 5 | Core: behaviour, emotion, expectation, progression, readiness |
| `andre-taxonomy-all-minus-emotion` | 19 | Comprehensive (most complete) |
| `andre-taxonomy-all-sales` | 8 | Sales behaviors: closing, collaborative, communication, listening, objection |
| `andre-taxonomy-combined` | 16 | Student + consultant behaviors |
| `andre-taxonomy-marketing` | 4 | Marketing touchpoints: ads, brochures, forms, website |
| `andre-taxonomy-student` | 10 | Student-focused behaviors |
| `andre-taxonomy-emotions-behaviors` | 2 | Consultant/student emotion taxonomies |

---

## Feature Evaluation Schema

### Per-Node Output (from "category" node)

```json
{
  "feature_evaluations": [
    {
      "feature_index_code": "4.A.i",
      "feature_name": "Explicit Career Goal Statement",
      "verdict": "present|unsure|not present",
      "likelihood": "very unlikely|unlikely|possible|likely|highly likely",
      "intensity": "very weak|weak|moderate|strong|very strong",
      "score": 1-5,
      "confidence": 0.0-1.0,
      "evidence": "Direct transcript excerpt...",
      "justification": "Explanation connecting evidence to checklist conditions..."
    }
  ]
}
```

### Aggregated Output (from "aggregation" node)

```json
{
  "feature_evaluations": [
    {
      "feature_index_code": "4.A.i",
      "feature_name": "Explicit Career Goal Statement",
      "verdict": "present",
      "likelihood": "highly likely",
      "intensity": "strong",
      "score": 4,
      "confidence": 0.85,
      "analyst_count": 3,  // How many nodes agreed
      "evidence": "Best representative excerpt...",
      "justification": "Synthesized justification from all agreeing nodes..."
    }
  ]
}
```

---

## Evaluation Dimensions

### 1. Verdict
| Value | Meaning |
|-------|---------|
| `present` | Clear evidence with satisfied checklist conditions |
| `unsure` | Some indicators but insufficient for confident determination |
| `not present` | No meaningful evidence or conditions satisfied |

### 2. Likelihood (5-point scale)
| Value | Meaning |
|-------|---------|
| `very unlikely` | No indicators, context suggests absence |
| `unlikely` | Minimal indicators, probably absent |
| `possible` | Some weak indicators, uncertain |
| `likely` | Multiple indicators, probably present |
| `highly likely` | Strong indicators, very confident |

### 3. Intensity (when feature present/likely)
| Value | Meaning |
|-------|---------|
| `very weak` | Minimal manifestation, barely detectable |
| `weak` | Limited manifestation, subtle presence |
| `moderate` | Clear manifestation, typical strength |
| `strong` | Pronounced manifestation, notable |
| `very strong` | Dominant manifestation, overwhelming |

### 4. Confidence (0.0-1.0)
| Range | Meaning |
|-------|---------|
| 0.0-0.2 | Very low confidence, highly uncertain |
| 0.3-0.4 | Low confidence, significant uncertainty |
| 0.5-0.6 | Moderate confidence, some uncertainty |
| 0.7-0.8 | High confidence, minimal uncertainty |
| 0.9-1.0 | Very high confidence, extremely certain |

### 5. Score (1-5)
Calculated based on:
- Verdict weighting (Present=4-5, Unsure=2-4, Not Present=1-2)
- Likelihood level contribution
- Intensity level contribution
- Confidence level influence

---

## Prompt Architecture

### System Prompt: `category-system.txt`

**Purpose:** Instruct LLM on comprehensive behavioral feature analysis methodology.

**Key Sections:**

1. **Taxonomy Comprehension**
   - Read each feature's definition, checklist conditions, logical rules
   - Review examples to calibrate condition recognition

2. **Transcript Analysis Preparation**
   - Read entire transcript for context
   - Note enrollment stage, progression status
   - Pay attention to explicit AND implicit indicators

3. **Systematic Feature Assessment**
   - Evaluate EVERY feature in taxonomy (no omissions)
   - Maintain consistent rigor across all features

4. **Condition-Based Evidence Collection**
   - Systematically evaluate each checklist condition
   - Extract specific transcript excerpts
   - Document which conditions are satisfied/unsatisfied

5. **Logical Rule Guidance**
   - For 3 conditions: Generally require 2 of 3 satisfied
   - For 2 conditions: Generally require both or 1 very strong
   - Use as guidance, not rigid requirements

**Quality Control Checklist (from prompt):**
```
- [ ] Every feature in taxonomy evaluated
- [ ] All assessment dimensions completed
- [ ] Evidence demonstrates rationale for verdicts
- [ ] Intensity ratings align with evidence strength
- [ ] Confidence levels reflect actual certainty
- [ ] Justifications connect to checklist conditions
- [ ] No isolated statements judged without context
- [ ] Consistency maintained across similar features
```

---

## Files Downloaded for Archetypes Pipeline

### Prompts (`prompts/andre-taxonomy-production-2/`)
- `category-system.txt` - Feature evaluation prompt (detailed methodology)
- `category-user.txt` - User message template
- `aggregation-system.txt` - Consensus synthesis prompt
- `aggregation-user.txt` - Aggregation user message

### Prompt Inputs (`prompt-inputs/andre-taxonomy-feature-4-new/`)
- `emotion1-taxonomy.txt` (20KB) - Primary emotion taxonomy
- `emotion2-taxonomy.txt` (12KB) - Secondary emotion taxonomy

### Additional Taxonomies (downloaded)
All 9 andre-taxonomy collections (71 files total) available in `prompt-inputs/`

### Configs (`configs/active/`)
- `andre-taxonomy-production-2.json` - Step 2 config (3+1 nodes, input catalog)

---

## Key Design Patterns

### 1. University Partitioning
- Enables university-specific benchmarking
- Same analysis across different consultant teams
- Comparative performance insights

### 2. Taxonomy-Driven Analysis
- Comprehensive feature coverage (no cherry-picking)
- Structured evaluation criteria
- Reproducible assessments

### 3. Multi-Dimensional Scoring
- Verdict + Likelihood + Intensity + Confidence + Score
- Rich signal for downstream analysis
- Enables nuanced filtering

### 4. Condition-Based Evidence
- Explicit checklist evaluation
- Evidence tied to specific conditions
- Transparent reasoning

### 5. Consensus with Analyst Count
- Track agreement level per feature
- Higher analyst_count = more reliable
- Identify contentious features

---

## Comparison: ENRO vs Archetypes

| Aspect | ENRO Pipeline | Archetypes Pipeline |
|--------|---------------|---------------------|
| **Focus** | Specific closing behaviors | Comprehensive all-feature extraction |
| **Steps** | 5 steps | 2 steps |
| **Filtering** | Multi-stage (call type, score) | Single-stage (university) |
| **Prompt Input** | `-pi closingv5` (behavior definition) | `-ic andre-taxonomy-*` (taxonomy catalog) |
| **Categories** | 6 fixed enrollment closing categories | All features in taxonomy (hundreds) |
| **Output** | Opportunities with coaching recommendations | Feature evaluations with multi-dimensional scores |
| **Use Case** | Sales coaching for closing skills | Comprehensive behavioral profiling |

---

*Generated: December 3, 2025*
