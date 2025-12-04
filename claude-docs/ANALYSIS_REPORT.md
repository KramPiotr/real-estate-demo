# OES LLM Processor - Comprehensive Prompts & Approaches Analysis

## Executive Summary

The OES LLM Processor repository implements a sophisticated multi-agent LLM processing system for analyzing university enrollment sales calls. The system uses behavioral definitions and opportunity identification frameworks to evaluate consultant performance across multiple domains. All prompts and configurations are stored in S3 (`s3://sentiment-ai-mab/`).

---

## Repository Architecture

### Core Processing Flows

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        OES LLM PROCESSOR ARCHITECTURE                        │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
        ┌───────────────────────────┼───────────────────────────┐
        │                           │                           │
        ▼                           ▼                           ▼
   ┌─────────┐               ┌─────────────┐              ┌─────────┐
   │COMPLIANCE│               │CAUSAL ANALYSIS│            │ARCHETYPES│
   └─────────┘               └─────────────┘              └─────────┘
        │                           │
        │                    ┌──────┴──────┐
        │                    │             │
        ▼                    ▼             ▼
   Call Recording        ┌──────┐    ┌──────────┐
   Disclosure           │CLOSING│    │OBJECTION │
   Compliance           │ ENRO  │    │  OBJE    │
                        └──────┘    └──────────┘
                             │             │
                             │      ┌──────┴──────┐
                             │      │             │
                             │      ▼             ▼
                             │  ┌──────────┐  ┌──────────┐
                             │  │CONSULTATIVE│ │COMMUNIC. │
                             │  │   CONS    │ │   COMM   │
                             │  └──────────┘  └──────────┘
                             │
                             ▼
                    ┌────────────────┐
                    │CAUSAL ANALYSIS │
                    │  Final Report  │
                    └────────────────┘
```

---

## 6 Main Processing Approaches

### 1. COMPLIANCE - Call Recording Disclosure
**Purpose:** Verify consultants follow legal/ethical disclosure requirements

**Config:** `compliance-enrolment-production-2-1`

**Prompt Flow:**
1. `check-system.txt` / `check-user.txt` - Initial compliance check
2. `validation-system.txt` / `validation-user.txt` - Validation layer
3. `errors-system.txt` / `errors-user.txt` - Error analysis

**Key Compliance Categories:**
- Call recording disclosure
- Census date disclosure
- Declaration requirements
- Fees disclosure
- Units/course structure disclosure

---

### 2. ENRO - Enrollment Closing
**Purpose:** Analyze consultant's closing behaviors and enrollment effectiveness

**Prompt Input:** `closingv5`
**Config:** `causal-behaviour-production-1-category-aggregation`

**6 Behavioral Sub-Categories:**

| Category | Description |
|----------|-------------|
| `teaching_period_confirmation` | Securing explicit agreement on specific start dates |
| `clear_action_plan_articulation` | Outlining specific, sequential enrollment steps |
| `documentation_submission_process_clarity` | Specifying required documents with deadlines |
| `mutual_commitment_establishment` | Creating explicit agreement on responsibilities |
| `proactive_follow_up_scheduling` | Establishing specific follow-up interactions |
| `psychological_readiness_expression` | Building student confidence to commit |

**Scoring Rubric (1-5):**
- 5: Exceptional - All elements present with specific dates/details
- 4: Strong - Good execution with minor gaps
- 3: Competent - Basic execution, limited depth
- 2: Basic - Vague, incomplete implementation
- 1: Minimal - Missing critical elements, may damage enrollment

---

### 3. OBJE - Objection Handling
**Purpose:** Evaluate consultant's ability to address student concerns

**Prompt Input:** `objection3`
**Config:** `causal-behaviour-production-1-category-aggregation`

**7 Objection Categories:**

| Category | Description |
|----------|-------------|
| `fees_affordability_concerns` | Cost, payment plans, financial barriers |
| `time_availability_for_studying` | Work-life-study balance concerns |
| `teaching_period_selection` | Start date preferences/timing |
| `institutional_value_proposition_concerns` | Why this university vs competitors |
| `browsing_without_intent_to_enroll` | Information gathering without commitment |
| `inconvenient_timing_for_discussion` | Bad time for call |
| `confidence_issues` | Self-doubt about academic capability |

**Critical Principles:**
1. **Veracity** - Never fabricate statistics or features
2. **Acknowledgment** - Always validate concerns without defensiveness
3. **Feasibility** - Never suggest workarounds for non-negotiable requirements
4. **Relevance** - Tailor responses to specific concerns

---

### 4. CONS - Consultative Approach
**Purpose:** Measure genuine discovery and need-finding behaviors

**Prompt Input:** `consultative1`
**Config:** `causal-behaviour-production-1-category-aggregation`

**5 Consultative Categories:**

| Category | Description |
|----------|-------------|
| `career_motivation_discovery` | Open-ended questions about career goals |
| `qualification_background_discovery` | Understanding educational/work background |
| `outcome_goals_discovery` | Exploring desired outcomes and success criteria |
| `deep_probing_follow_up` | Persistent exploration beyond surface answers |
| `pre_closing_value_paraphrasing` | Summarizing motivations before enrollment ask |

**Key Rules:**
- For brochure downloads: NEVER ask "Do you have questions about the brochure?" - go directly to WHY questions
- For web applications: Acknowledge application THEN pivot to discovery
- Must paraphrase before closing (hard rule)

---

### 5. ARCHETYPES - University-Specific Analysis
**Purpose:** Create university-filtered transcript directories for analysis

**Universities Supported:**
- Monash (Group of 8)
- SOL (Southern Cross Online)
- Federation University
- QUT
- WSU

**Process:**
1. Download transcripts from S3
2. Filter by team name from CSV metadata
3. Upload filtered transcripts to university-specific S3 paths
4. Run feature extraction

---

### 6. CAUSAL ANALYSIS - Final Synthesis
**Purpose:** Generate comprehensive coaching reports

**Config:** `causal-analysis-production-7-closing-new-ui-timestamps`

**18 Prompt Files for Multi-Stage Analysis:**
- `behaviour_first-system/user.txt`
- `behaviour_second-system/user.txt`
- `behaviour_third-system/user.txt`
- `condense_analysis-system/user.txt`
- `recommended_improvement-system/user.txt`
- `response_accuracy-system/user.txt`
- `response_analysis-system/user.txt`
- `response_validation-system/user.txt`
- `trigger_identification-system/user.txt`

---

## Multi-Agent Batch Processing Architecture

### Node Structure (Consensus-Based)

```
┌─────────────────────────────────────────────────────────┐
│                    MULTI-AGENT BATCH                     │
└─────────────────────────────────────────────────────────┘
                           │
          ┌────────────────┼────────────────┐
          │                │                │
          ▼                ▼                ▼
    ┌─────────┐      ┌─────────┐      ┌─────────┐
    │ Node 0  │      │ Node 1  │      │ Node 2  │
    │(Azure)  │      │(Azure)  │      │(Azure)  │
    └─────────┘      └─────────┘      └─────────┘
          │                │                │
          └────────────────┼────────────────┘
                           │
                           ▼
                  ┌─────────────────┐
                  │  AGGREGATION    │
                  │   (Consensus)   │
                  │  2+ Agreement   │
                  └─────────────────┘
                           │
                           ▼
                  ┌─────────────────┐
                  │ Final Output    │
                  │ with node_indices│
                  └─────────────────┘
```

### Consensus Requirements
- **3/3 Agreement:** High confidence opportunity
- **2/3 Agreement:** Moderate confidence, included in output
- **1/3 Agreement:** Excluded from final results

### Aggregation Process
1. **Semantic Clustering** - Match opportunities by transcript range overlap + category similarity
2. **Quote Selection** - Choose best representative quote from agreeing nodes
3. **Score Reconciliation** - Synthesize scores using behavioral definition alignment
4. **Justification Synthesis** - Combine multiple node perspectives
5. **Unique ID Assignment** - Sequential external_id starting from 1

---

## S3 Storage Structure

```
s3://sentiment-ai-mab/
├── configs/active/
│   ├── causal-behaviour-production-1-category-aggregation.json
│   ├── causal-analysis-production-7-closing-new-ui-timestamps.json
│   ├── compliance-enrolment-production-2-1.json
│   ├── next-steps_categorisation-3.json
│   └── ... (100+ configs)
│
├── prompt-inputs/
│   ├── causals/
│   │   ├── objection3-definition.txt     # Objection handling behaviors
│   │   ├── objection3-opportunity.txt    # Opportunity identification
│   │   ├── consultative1-definition.txt  # Consultative behaviors
│   │   ├── consultative1-opportunity.txt
│   │   ├── closingv5-definition.txt      # Enrollment closing behaviors
│   │   ├── closingv5-opportunity.txt
│   │   └── ... (50+ causal files)
│   │
│   ├── all_compliance/
│   │   ├── call_recording_disclosure-broad.txt
│   │   ├── call_recording_disclosure-enhanced.txt
│   │   ├── census-broad.txt / census-enhanced.txt
│   │   ├── declaration-broad.txt / declaration-enhanced.txt
│   │   ├── fees-broad.txt / fees-enhanced.txt
│   │   └── units-broad.txt / units-enhanced.txt
│   │
│   ├── behavioural-definitions/
│   │   ├── closing-definition.txt
│   │   ├── collaborative-definition.txt
│   │   ├── communication-definition.txt
│   │   ├── objections-definition.txt
│   │   └── ... (15 definition files)
│   │
│   └── andre-taxonomy-sales/
│       ├── closing-taxonomy.txt
│       ├── collaborative-taxonomy.txt
│       ├── communication-taxonomy.txt
│       ├── listening-taxonomy.txt
│       └── objection-taxonomy.txt
│
├── prompts/
│   ├── causal-behaviour-production-1-category-aggregation/
│   │   ├── aggregation-system.txt / aggregation-user.txt
│   │   └── opportunity-system.txt / opportunity-user.txt
│   │
│   ├── causal-analysis-production-7-closing-new-ui-timestamps/
│   │   └── (18 prompt files for multi-stage analysis)
│   │
│   ├── compliance-enrolment-production-2-1/
│   │   ├── check-system.txt / check-user.txt
│   │   ├── validation-system.txt / validation-user.txt
│   │   └── errors-system.txt / errors-user.txt
│   │
│   └── next-steps_categorisation-3/
│       └── check-system.txt / check-user.txt
│
└── transcripts/
    └── weekly-analysis-{date-range}/
```

---

## Key Prompt Design Patterns

### 1. Definition + Opportunity Structure
Each behavior has two complementary files:
- **Definition file:** Comprehensive behavioral rubric (scoring 1-5)
- **Opportunity file:** Identification criteria for moments in transcripts

### 2. Gold Standard Analysis Template
Every analysis must include:
1. Direct consultant quote
2. Effectiveness explanation
3. Specific technique identification
4. Comparison to weak alternatives
5. Connection to enrollment/retention outcomes
6. Pattern alignment
7. Forward impact statement

### 3. Rule-Based Scoring
Example from Documentation Submission:
- **Step 1:** Does response name specific documents? (Primary filter)
  - YES → Eligible for scores 3-5
  - NO → Automatic scores 1-2
- **Step 2:** Additional factors (deadline, method, connection to benefits)

### 4. Lead Source Rules
- **Brochure Downloads:** Never ask about brochure, go directly to WHY questions
- **Web Applications:** Acknowledge application → Pivot to discovery → Document request

---

## Output Schemas

### Opportunity Output (Per Node)
```json
{
  "opportunities": [
    {
      "id": 1,
      "category": "fees_affordability_concerns",
      "id_range": "15-23",
      "representative_quote": "Student: [...] | Consultant: [...]",
      "strength_score": 4,
      "explanation": "Detailed justification..."
    }
  ]
}
```

### Aggregated Output
```json
{
  "aggregated_opportunities": [
    {
      "external_id": 1,
      "external_opportunity_id": "685129713117",
      "behaviour": "Objection Handling",
      "sub_behaviour": "confidence_issues",
      "transcript_range": "25-34",
      "quote": "Student: [...] | Consultant: [...]",
      "score": 4,
      "justification": "All three nodes identified...",
      "agreement_count": 3,
      "node_indices": [0, 1, 2]
    }
  ]
}
```

### Compliance Output
```json
{
  "requirement": "Call Recording Disclosure",
  "verdict": "Full compliance / Partial compliance / No compliance",
  "evidence": {
    "text": "Relevant text from transcript",
    "segment_id": "0",
    "timestamp": "2.56 - 24.84"
  },
  "reasoning": "Detailed explanation...",
  "sub_requirements_analysis": [...]
}
```

---

## Downloaded Files Summary

### Prompt Inputs (Local: `oes-analysis/prompt-inputs/`)
- `causals/` - 55 files including objection3, consultative1, closingv5
- `all_compliance/` - 11 compliance definition files
- `behavioural-definitions/` - 15 core behavior definitions
- `andre-taxonomy-sales/` - 5 sales taxonomy files

### Prompts (Local: `oes-analysis/prompts/`)
- `causal-behaviour-production-1-category-aggregation/` - 4 prompt files
- `causal-analysis-production-7-closing-new-ui-timestamps/` - 18 prompt files
- `compliance-enrolment-production-2-1/` - 6 prompt files
- `next-steps_categorisation-3/` - 2 prompt files

### Configs (Local: `oes-analysis/configs/active/`)
- 100+ configuration files defining processing workflows

---

## Key Insights for Real Estate Adaptation

### Transferable Concepts:
1. **Multi-agent consensus** - Reduces LLM hallucination risk
2. **Behavioral scoring rubrics** - Objective 1-5 scoring frameworks
3. **Opportunity identification** - Finding coaching moments in calls
4. **Lead source rules** - Different approaches for different lead types
5. **Compliance checking** - Regulatory/legal requirement verification
6. **Gold standard analysis format** - Consistent evaluation methodology

### Domain-Specific Elements to Adapt:
- University enrollment → Real estate sales
- Teaching periods → Property viewings/offers
- Documentation (transcripts, citizenship) → Buyer documentation
- Course value proposition → Property value proposition
- Objection categories → Real estate objections

---

*Generated: December 3, 2025*
*Source: s3://sentiment-ai-mab/ + /Users/piotrkram/programming/oes-llm-processor*
