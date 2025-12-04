# ENRO Pipeline - Enrollment Closing Analysis

## Overview

The ENRO (Enrollment Closing) pipeline analyzes sales call transcripts to identify and evaluate consultant behaviors related to closing enrollment opportunities. It uses a 5-step process combining LLM analysis with Python aggregation scripts.

---

## Pipeline Flow Diagram

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                              ENRO PIPELINE - 5 STEPS                                 │
└─────────────────────────────────────────────────────────────────────────────────────┘

Step 1: CALL CLASSIFICATION
┌────────────────────────────────────────────────────────────────────────────────────┐
│  INPUT: Raw transcripts from S3                                                     │
│  ├── s3://sentiment-ai-mab/transcripts/{start-date}-{end-date}                     │
│                                                                                     │
│  PROCESS: multi-agent-batch                                                         │
│  ├── Config: next-steps_categorisation-3                                           │
│  ├── 5 Azure LLM nodes (mini models)                                               │
│  ├── Classifies: call_type + education_interest                                    │
│  └── No prompt-input (transcript only)                                             │
│                                                                                     │
│  OUTPUT: JSON with call classifications                                             │
│  └── partial_results/next-steps_categorisation-3__week-{N}/                        │
└────────────────────────────────────────────────────────────────────────────────────┘
                                        │
                                        ▼
Step 2: CONSULTATION FILTERING (Python)
┌────────────────────────────────────────────────────────────────────────────────────┐
│  INPUT: Step 1 results + Original transcripts                                       │
│                                                                                     │
│  PROCESS: oes-filter-consultation-transcripts                                       │
│  ├── Reads classifications from Step 1                                             │
│  ├── Applies consensus rule: 3+ of 5 models must agree                             │
│  ├── Filters for: INITIAL_CONSULTATION or FOLLOWUP_CONSULTATION                    │
│  ├── Excludes: BACHELOR_OF_EDUCATION interest                                      │
│  └── Copies eligible transcripts to new directory                                  │
│                                                                                     │
│  OUTPUT: Filtered "closing-eligible" transcripts                                    │
│  ├── LOCAL: transcripts/weekly-analysis-{date}-closing-eligible/closing/          │
│  └── S3: s3://sentiment-ai-mab/transcripts/{date}-closing-eligible                 │
└────────────────────────────────────────────────────────────────────────────────────┘
                                        │
                                        ▼
Step 3: BEHAVIORAL OPPORTUNITY IDENTIFICATION
┌────────────────────────────────────────────────────────────────────────────────────┐
│  INPUT: Closing-eligible transcripts + Behavioral definition                        │
│  ├── Transcripts: {date}-closing-eligible                                          │
│  └── Prompt-input: closingv5 (definition + opportunity files)                      │
│                                                                                     │
│  PROCESS: multi-agent-batch                                                         │
│  ├── Config: causal-behaviour-production-1-category-aggregation                    │
│  ├── TWO-STAGE ARCHITECTURE:                                                       │
│  │   ├── Node 1 "opportunity": 3 Azure LLM nodes (independent)                     │
│  │   │   └── Each identifies opportunities with quotes, scores, categories         │
│  │   └── Node 2 "aggregation": 1 Azure LLM node                                    │
│  │       └── Aggregates 3 node outputs, requires 2+ agreement                      │
│  │                                                                                 │
│  ├── Opportunity Schema (per node):                                                │
│  │   {id, category, id_range, representative_quote, strength_score, explanation}   │
│  │                                                                                 │
│  └── Aggregated Schema:                                                            │
│      {external_id, behaviour, sub_behaviour, transcript_range, quote,              │
│       score, justification, agreement_count, node_indices}                         │
│                                                                                     │
│  OUTPUT: Aggregated opportunities with consensus                                    │
│  └── partial_results/causal-behaviour-...-closing-eligible/closingv5/closing/      │
└────────────────────────────────────────────────────────────────────────────────────┘
                                        │
                                        ▼
Step 4: SCORE AGGREGATION & TRANSCRIPT ANNOTATION (Python)
┌────────────────────────────────────────────────────────────────────────────────────┐
│  INPUT: Step 3 aggregated results + Original transcripts + CSV metadata            │
│                                                                                     │
│  PROCESS: oes-aggregate-enrollment-closing                                          │
│  ├── Reads aggregated opportunities from Step 3                                    │
│  ├── Filters for high-scoring opportunities (score >= 4)                           │
│  ├── Fuzzy matches categories to canonical names                                   │
│  ├── Creates per-category output directories                                       │
│  ├── Augments transcripts with opportunity annotations                             │
│  │   └── Adds markers: opportunity_{id} = "start/end of opportunity id {id}"      │
│  ├── Calculates statistics by consultant and team                                  │
│  └── Generates JSON statistics files                                               │
│                                                                                     │
│  OUTPUT:                                                                            │
│  ├── Annotated transcripts by category:                                            │
│  │   └── transcripts/weekly-analysis-{date}-ENRO-annotated/                        │
│  │       ├── proactive-follow-up-scheduling/                                       │
│  │       ├── clear-action-plan-articulation/                                       │
│  │       ├── teaching-period-confirmation/                                         │
│  │       ├── documentation-submission-process-clarity/                             │
│  │       ├── mutual-commitment-establishment/                                      │
│  │       └── psychological-readiness-expression/                                   │
│  │                                                                                 │
│  ├── Statistics files:                                                             │
│  │   └── causal-aggregation/week-{N}/                                             │
│  │       ├── closing_statistics.json                                               │
│  │       └── closing_category_statistics.json                                      │
│  │                                                                                 │
│  └── S3: s3://sentiment-ai-mab/transcripts/{date}-ENRO-annotated                  │
└────────────────────────────────────────────────────────────────────────────────────┘
                                        │
                                        ▼
Step 5: CAUSAL ANALYSIS (Final Coaching Report)
┌────────────────────────────────────────────────────────────────────────────────────┐
│  INPUT: ENRO-annotated transcripts + Behavioral definition                          │
│  ├── Transcripts: {date}-ENRO-annotated                                            │
│  └── Prompt-input: closingv5                                                       │
│                                                                                     │
│  PROCESS: multi-agent-batch                                                         │
│  ├── Config: causal-analysis-production-7-closing-new-ui-timestamps                │
│  ├── MULTI-STAGE NODE ARCHITECTURE (9 nodes):                                      │
│  │   ├── behaviour_first, behaviour_second, behaviour_third                        │
│  │   ├── trigger_identification                                                    │
│  │   ├── response_analysis, response_accuracy, response_validation                 │
│  │   ├── recommended_improvement                                                   │
│  │   └── condense_analysis (final synthesis)                                       │
│  │                                                                                 │
│  └── Generates detailed coaching analysis per opportunity                          │
│                                                                                     │
│  OUTPUT: Final analysis with coaching recommendations                               │
│  └── partial_results/causal-analysis-...-{date}-ENRO-annotated/                    │
└────────────────────────────────────────────────────────────────────────────────────┘
```

---

## Step-by-Step Details

### Step 1: Next-Steps Categorisation

**Script:** `1-next-steps-categorisation.sh`

**Purpose:** Classify all calls by type and education interest to filter for closing-eligible calls.

**Command:**
```bash
uv run multi-agent-batch \
    -c next-steps_categorisation-3 \
    -s -p \
    -sm s3 \
    -t "{{START_DATE}}-{{END_DATE}}" \
    -f "over-2-mins" \
    -l gemini \
    -e west-us \
    -ss "{{WEEK_ID}}"
```

**Config:** `next-steps_categorisation-3.json`
- Uses 5 Azure mini models running in parallel
- Single "check" node (no aggregation - consensus done in Step 2)

**Classification Categories:**

| Field | Values | Purpose |
|-------|--------|---------|
| `call_type` | INITIAL_CONSULTATION, FOLLOWUP_CONSULTATION, ENROLLMENT_CALL, OTHER | Identify consultation calls |
| `education_interest` | BACHELOR_OF_EDUCATION, OTHER_EDUCATION, NON_EDUCATION | Filter out B.Ed interest |

**Prompt:** `check-system.txt`
- Detailed step-by-step analysis process
- Explicit indicators for each classification
- Chain of thought reasoning requirements
- Evidence collection with quotes and context

---

### Step 2: Consultation Filtering (Python)

**Script:** `2-aggregate-closing-categorisation.sh`
**Entry Point:** `oes-filter-consultation-transcripts`
**Python File:** `closing_categorization/filter_consultation_transcripts.py`

**Purpose:** Apply consensus voting and copy eligible transcripts.

**Key Logic:**
```python
# Consensus rule: 3+ of 5 models must agree
for val, count in ct_counter.items():
    if count >= 3:  # Majority consensus
        if val in {"INITIAL_CONSULTATION", "FOLLOWUP_CONSULTATION"}:
            is_consultation = True

# Filter criteria: Consultation AND NOT Bachelor of Education
if is_consultation and not is_bachelor_education:
    filtered_files.append(file_basename)
```

**Output Statistics:**
- Total transcripts processed
- Consultation calls (%)
- Bachelor of Education inquiries (%)
- Consultation calls NOT about B.Ed (%) ← These become "closing-eligible"

---

### Step 3: Causal Behaviour Aggregation

**Script:** `3-causal-behaviour-aggregation.sh`

**Purpose:** Identify enrollment closing opportunities using consensus-based multi-agent analysis.

**Command:**
```bash
uv run multi-agent-batch \
    -c causal-behaviour-production-1-category-aggregation \
    -sm s3 \
    -t "{{START_DATE}}-{{END_DATE}}-closing-eligible" \
    -f "over-2-mins" \
    -e east-us \
    -pi closingv5 \
    -l gemini \
    -ss "{{WEEK_ID}}-closing-eligible" \
    -s -p
```

**Prompt Input:** `closingv5`
- `closingv5-definition.txt` (56KB) - Comprehensive behavioral rubric with scoring 1-5
- `closingv5-opportunity.txt` (50KB) - Opportunity identification criteria

**6 Behavioral Categories (sub_behaviour):**

| Category | Snake_Case Name | Description |
|----------|-----------------|-------------|
| Teaching Period Confirmation | `teaching_period_confirmation` | Securing commitment to specific start dates |
| Clear Action Plan Articulation | `clear_action_plan_articulation` | Outlining sequential enrollment steps |
| Documentation Submission | `documentation_submission_process_clarity` | Specifying required documents with deadlines |
| Mutual Commitment | `mutual_commitment_establishment` | Creating explicit agreement on responsibilities |
| Follow-Up Scheduling | `proactive_follow_up_scheduling` | Establishing specific follow-up interactions |
| Psychological Readiness | `psychological_readiness_expression` | Building student confidence to commit |

**Two-Stage Architecture:**

```
Stage 1: OPPORTUNITY IDENTIFICATION (3 parallel nodes)
┌─────────────────────────────────────────────────────────────┐
│  Node 0 (Azure)  │  Node 1 (Azure)  │  Node 2 (Azure)       │
│  ─────────────   │  ─────────────   │  ─────────────        │
│  Independent     │  Independent     │  Independent          │
│  opportunity     │  opportunity     │  opportunity          │
│  identification  │  identification  │  identification       │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
Stage 2: CONSENSUS AGGREGATION (1 node)
┌─────────────────────────────────────────────────────────────┐
│  Aggregation Node (Azure)                                    │
│  ─────────────────────────                                   │
│  • Semantic matching (NOT by ID)                            │
│  • Requires 2+ node agreement                               │
│  • Selects best quote and range                             │
│  • Synthesizes justifications                               │
│  • Assigns unique sequential IDs                            │
└─────────────────────────────────────────────────────────────┘
```

**Aggregation Prompt:** `aggregation-system.txt`
- Semantic opportunity matching using transcript range overlap
- Strong match: Overlapping ranges + same category + similar justification
- Consensus building: 3/3 = high confidence, 2/3 = moderate, 1/3 = excluded
- Evidence synthesis: Select best quotes, reconcile scores

---

### Step 4: Score Aggregation (Python)

**Script:** `4-aggregate-causal-scores.sh`
**Entry Point:** `oes-aggregate-enrollment-closing`
**Python File:** `causal_analysis/aggregate_enrollment_closing_scores.py`

**Purpose:** Process aggregated results, annotate transcripts, calculate statistics.

**Key Processing:**
1. Read aggregated opportunities from Step 3
2. Filter for high scores (strength_score >= 4)
3. Fuzzy match categories to canonical names
4. Create per-category output directories
5. Augment transcripts with opportunity markers
6. Calculate consultant/team statistics

**Transcript Annotation Format:**
```json
{
  "id": 25,
  "text": "Were you looking to commence in July?",
  "speaker": "Consultant",
  "opportunity_1": "start of opportunity id 1",
  "category": "teaching_period_confirmation"
}
```

**Statistics Output:**
- `closing_statistics.json` - Per-consultant opportunity counts
- `closing_category_statistics.json` - Category breakdown by consultant/team

---

### Step 5: Causal Analysis (Final Report)

**Script:** `5-causal-analysis.sh`

**Purpose:** Generate comprehensive coaching analysis with recommendations.

**Command:**
```bash
uv run multi-agent-batch \
    -c causal-analysis-production-7-closing-new-ui-timestamps \
    -sm s3 \
    -t "{{START_DATE}}-{{END_DATE}}-ENRO-annotated" \
    -pi "closingv5" \
    -e west-us \
    -l gemini \
    -ss "{{WEEK_ID}}-ENRO-annotated" \
    -f "over-2-mins" \
    -s -p
```

**Config:** `causal-analysis-production-7-closing-new-ui-timestamps.json`
- 9 processing nodes for multi-stage analysis
- Generates detailed coaching insights

**Processing Stages:**
1. **behaviour_first/second/third** - Multi-perspective behavioral analysis
2. **trigger_identification** - Identify what triggered the opportunity
3. **response_analysis** - Evaluate consultant's response quality
4. **response_accuracy** - Verify accuracy of consultant statements
5. **response_validation** - Cross-validate findings
6. **recommended_improvement** - Generate coaching recommendations
7. **condense_analysis** - Final synthesis into coaching report

---

## Files Downloaded for ENRO Pipeline

### Prompts (`prompts/`)
- `next-steps_categorisation-3/check-system.txt` - Call classification prompt
- `causal-behaviour-production-1-category-aggregation/opportunity-system.txt` - Opportunity identification
- `causal-behaviour-production-1-category-aggregation/aggregation-system.txt` - Consensus aggregation
- `causal-analysis-production-7-closing-new-ui-timestamps/` - 18 prompt files for final analysis

### Prompt Inputs (`prompt-inputs/causals/`)
- `closingv5-definition.txt` - Behavioral scoring rubric (56KB)
- `closingv5-opportunity.txt` - Opportunity identification criteria (50KB)
- `closingv5-special.txt`, `closingv5-special2.txt`, `closingv5-special3.txt` - Additional context

### Configs (`configs/active/`)
- `next-steps_categorisation-3.json` - Step 1 config (5 nodes, no aggregation)
- `causal-behaviour-production-1-category-aggregation.json` - Step 3 config (3+1 nodes)
- `causal-analysis-production-7-closing-new-ui-timestamps.json` - Step 5 config (9 nodes)

---

## Key Design Patterns

### 1. Multi-Stage Filtering
- Start with all calls
- Filter to consultation calls (Step 2)
- Filter to high-scoring opportunities (Step 4)
- Each stage reduces noise for downstream analysis

### 2. Consensus-Based Reliability
- Multiple independent LLM nodes
- Require 2+ agreement for inclusion
- Reduces hallucination risk
- Provides confidence metrics

### 3. Human-in-the-Loop Aggregation
- LLM identifies opportunities
- Python applies business rules
- Final output structured for human review

### 4. Progressive Enrichment
- Raw transcript → Classified → Filtered → Annotated → Analyzed
- Each step adds metadata without losing original data
- Fully traceable from final report to original transcript

---

*Generated: December 3, 2025*
