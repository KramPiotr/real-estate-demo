# Real Estate Sales Call Analysis - Pipeline Proposals

## Executive Summary

Based on the OES LLM Processor patterns, I propose **6 pipeline systems** for real estate sales call analysis:

| Pipeline | Purpose | Inspired By |
|----------|---------|-------------|
| **LEAD-SCORE** | Lead prioritization & buy probability | ENRO + Archetypes hybrid |
| **URGENT-FLAG** | Immediate action flagging | Compliance pipeline |
| **AGENT-COACH** | Agent performance & coaching | ENRO causal analysis |
| **BUYER-JOURNEY** | Journey stage classification | Next-steps categorisation |
| **OBJECTION-MAP** | Objection tracking & resolution | OBJE pipeline |
| **PROPERTY-MATCH** | Property-buyer fit analysis | New concept |

---

# Pipeline 1: LEAD-SCORE (Lead Prioritization)

## Purpose
Score and prioritize leads based on likelihood to purchase, engagement level, and buyer readiness signals.

## Pipeline Architecture (4 Steps)

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                           LEAD-SCORE PIPELINE                                        │
└─────────────────────────────────────────────────────────────────────────────────────┘

Step 1: BUYER INTENT CLASSIFICATION (LLM - 5 nodes)
┌────────────────────────────────────────────────────────────────────────────────────┐
│  Config: buyer-intent-classification-1                                              │
│  Prompt: Classify buyer intent and timeline                                         │
│                                                                                     │
│  Classifications:                                                                   │
│  ├── buyer_stage: BROWSING | ACTIVELY_SEARCHING | READY_TO_OFFER | UNDER_CONTRACT  │
│  ├── timeline: IMMEDIATE (<30 days) | SHORT_TERM (1-3 mo) | MEDIUM (3-6) | LONG    │
│  ├── financing_status: PRE_APPROVED | IN_PROCESS | NOT_STARTED | CASH_BUYER        │
│  └── motivation_level: HIGH | MEDIUM | LOW | UNCLEAR                               │
└────────────────────────────────────────────────────────────────────────────────────┘
                                        │
                                        ▼
Step 2: POSITIVE SIGNAL EXTRACTION (LLM - 3+1 nodes)
┌────────────────────────────────────────────────────────────────────────────────────┐
│  Config: buyer-signals-positive-1                                                   │
│  Prompt-input: positive-signals-definition.txt                                      │
│                                                                                     │
│  Positive Signal Categories:                                                        │
│  ├── financial_readiness          (pre-approval, deposit ready, budget clarity)    │
│  ├── timeline_urgency             (lease ending, job relocation, life event)       │
│  ├── decision_maker_engagement    (both partners present, family consensus)        │
│  ├── property_specificity         (knows exactly what they want)                   │
│  ├── repeat_engagement            (multiple viewings, callbacks, questions)        │
│  └── commitment_language          ("we love it", "this is the one", offer talk)   │
│                                                                                     │
│  Output: List of positive signals with quotes, scores (1-5), confidence            │
└────────────────────────────────────────────────────────────────────────────────────┘
                                        │
                                        ▼
Step 3: NEGATIVE SIGNAL EXTRACTION (LLM - 3+1 nodes)
┌────────────────────────────────────────────────────────────────────────────────────┐
│  Config: buyer-signals-negative-1                                                   │
│  Prompt-input: negative-signals-definition.txt                                      │
│                                                                                     │
│  Negative Signal Categories:                                                        │
│  ├── financial_barriers           (no pre-approval, budget mismatch, job concerns) │
│  ├── decision_paralysis           (can't commit, needs more options, indecisive)   │
│  ├── external_blockers            (pending sale, divorce, family disagreement)     │
│  ├── unrealistic_expectations     (champagne taste, beer budget)                   │
│  ├── competitor_preference        (working with other agents, comparing)           │
│  └── disengagement_signals        (ghosting, rescheduling, excuse patterns)        │
│                                                                                     │
│  Output: List of negative signals with quotes, severity (1-5), confidence          │
└────────────────────────────────────────────────────────────────────────────────────┘
                                        │
                                        ▼
Step 4: LEAD SCORE AGGREGATION (Python)
┌────────────────────────────────────────────────────────────────────────────────────┐
│  Script: calculate-lead-scores.py                                                   │
│                                                                                     │
│  Scoring Formula:                                                                   │
│  ├── Base Score = Stage Weight × Timeline Weight × Financing Weight                │
│  ├── Positive Boost = Σ(positive_signal_score × category_weight)                   │
│  ├── Negative Penalty = Σ(negative_signal_severity × category_weight)              │
│  └── Final Score = Base + Positive Boost - Negative Penalty (0-100 scale)          │
│                                                                                     │
│  Output:                                                                            │
│  ├── Prioritized lead list (sorted by score)                                       │
│  ├── Per-lead breakdown (what's driving the score)                                 │
│  ├── Action recommendations per tier                                               │
│  └── Hot leads alert (score > 80)                                                  │
└────────────────────────────────────────────────────────────────────────────────────┘
```

## Prompt Input: `positive-signals-definition.txt`

```markdown
# Positive Buyer Signals - Behavioral Definition

## 1. Financial Readiness (`financial_readiness`)

### Definition
Buyer demonstrates clear financial preparation and capability to complete a purchase.

### Checklist Conditions (require 2 of 3)
- [ ] Mentions pre-approval, mortgage approval, or specific lender
- [ ] States specific budget with confidence (not "around" or "maybe")
- [ ] References deposit/down payment availability or proof of funds

### Scoring Rubric
| Score | Criteria |
|-------|----------|
| 5 | Pre-approved with letter in hand, cash buyer, or deposit ready |
| 4 | Pre-approval in progress with specific lender, clear budget |
| 3 | Has spoken to lender, general budget range established |
| 2 | Vague budget, hasn't started financing conversation |
| 1 | No financial discussion, unclear ability to purchase |

### Example (Score 5)
> Buyer: "We got our pre-approval last week for $750k, and we have 20% ready to go. Our broker said we could close in 30 days."

### Example (Score 2)
> Buyer: "We're probably looking around $600k, maybe $700k if we really love it. Haven't talked to a bank yet."

---

## 2. Timeline Urgency (`timeline_urgency`)

### Definition
Buyer has external pressure or motivation creating a real deadline for purchase.

### Checklist Conditions (require 2 of 3)
- [ ] Mentions specific deadline (lease end, job start, school year)
- [ ] Expresses urgency language ("need to", "have to", "must")
- [ ] References life event driving timeline (baby, marriage, divorce, relocation)

### Scoring Rubric
| Score | Criteria |
|-------|----------|
| 5 | Hard deadline within 30 days (lease ends, job starts, closing on sale) |
| 4 | Deadline within 60 days, strong motivation expressed |
| 3 | Soft deadline within 3 months, moderate urgency |
| 2 | Vague timeline ("sometime this year"), no external pressure |
| 1 | No timeline, "just looking", browsing mode |

...

## 3. Decision Maker Engagement (`decision_maker_engagement`)
## 4. Property Specificity (`property_specificity`)
## 5. Repeat Engagement (`repeat_engagement`)
## 6. Commitment Language (`commitment_language`)
```

## Config: `buyer-intent-classification-1.json`

```json
{
  "nodes": [
    {
      "name": "classify",
      "inputs": ["transcript"],
      "models": [
        {"provider": "azure", "mini": true},
        {"provider": "azure", "mini": true},
        {"provider": "azure", "mini": true},
        {"provider": "azure", "mini": true},
        {"provider": "azure", "mini": true}
      ],
      "response_format_schema": {
        "type": "object",
        "properties": {
          "buyer_classification": {
            "type": "object",
            "properties": {
              "buyer_stage": {
                "type": "string",
                "enum": ["BROWSING", "ACTIVELY_SEARCHING", "READY_TO_OFFER", "UNDER_CONTRACT"]
              },
              "timeline": {
                "type": "string",
                "enum": ["IMMEDIATE", "SHORT_TERM", "MEDIUM_TERM", "LONG_TERM", "UNCLEAR"]
              },
              "financing_status": {
                "type": "string",
                "enum": ["PRE_APPROVED", "IN_PROCESS", "NOT_STARTED", "CASH_BUYER", "UNKNOWN"]
              },
              "motivation_level": {
                "type": "string",
                "enum": ["HIGH", "MEDIUM", "LOW", "UNCLEAR"]
              },
              "evidence": {
                "type": "array",
                "items": {
                  "type": "object",
                  "properties": {
                    "field": {"type": "string"},
                    "quote": {"type": "string"},
                    "reasoning": {"type": "string"}
                  }
                }
              }
            }
          }
        }
      }
    }
  ]
}
```

---

# Pipeline 2: URGENT-FLAG (Immediate Action Required)

## Purpose
Identify calls that require immediate follow-up action due to time-sensitive situations, competitor threats, or high-value opportunities.

## Pipeline Architecture (2 Steps)

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                           URGENT-FLAG PIPELINE                                       │
└─────────────────────────────────────────────────────────────────────────────────────┘

Step 1: URGENCY DETECTION (LLM - 3 nodes + aggregation)
┌────────────────────────────────────────────────────────────────────────────────────┐
│  Config: urgency-detection-1                                                        │
│  Prompt-input: urgency-flags-definition.txt                                         │
│                                                                                     │
│  Flag Categories (with severity: CRITICAL | HIGH | MEDIUM):                         │
│                                                                                     │
│  CRITICAL FLAGS (immediate response needed):                                        │
│  ├── competitor_offer_pending     "We have another offer on the table"             │
│  ├── deadline_today               "We need to decide by end of day"                │
│  ├── viewing_with_competitor      "We're seeing another property this afternoon"   │
│  ├── emotional_peak               "We absolutely love this house" (strike while hot)│
│                                                                                     │
│  HIGH FLAGS (respond within 2 hours):                                               │
│  ├── price_objection_serious      "It's just too expensive for us"                 │
│  ├── losing_interest              "Maybe we should keep looking"                   │
│  ├── requested_callback           "Can you call me back before 5pm?"               │
│  ├── inspection_concern           "We're worried about the foundation"             │
│                                                                                     │
│  MEDIUM FLAGS (respond within 24 hours):                                            │
│  ├── needs_more_info              "Can you send me the HOA docs?"                  │
│  ├── wants_second_viewing         "Can we come back with my parents?"              │
│  ├── financing_question           "What would my monthly payment be?"              │
│  └── negotiation_signal           "Would they consider a lower offer?"             │
└────────────────────────────────────────────────────────────────────────────────────┘
                                        │
                                        ▼
Step 2: ALERT GENERATION (Python)
┌────────────────────────────────────────────────────────────────────────────────────┐
│  Script: generate-urgent-alerts.py                                                  │
│                                                                                     │
│  Actions:                                                                           │
│  ├── CRITICAL → Slack/SMS alert to agent + manager                                 │
│  ├── HIGH → Email alert + task creation in CRM                                     │
│  ├── MEDIUM → Daily digest + CRM task                                              │
│                                                                                     │
│  Output:                                                                            │
│  ├── alerts.json (structured for integration)                                      │
│  ├── urgent_calls_report.html (human-readable)                                     │
│  └── CRM webhook payloads                                                          │
└────────────────────────────────────────────────────────────────────────────────────┘
```

## Prompt Input: `urgency-flags-definition.txt`

```markdown
# Urgency Flags - Detection Definition

## CRITICAL: Competitor Offer Pending (`competitor_offer_pending`)

### Definition
Buyer indicates they have or are considering a competing offer, creating immediate risk of losing the deal.

### Detection Phrases
- "We have another offer"
- "The other agent said..."
- "We're also looking at [address]"
- "Another property we like"
- "We need to compare"

### Severity: CRITICAL
### Response Window: Immediate (within 30 minutes)

### Required Action
Agent must call back immediately with:
1. Acknowledge the competition
2. Reinforce unique value of current property
3. Offer to expedite any pending items
4. Consider pre-emptive offer strategy discussion

### Example Detection
> Buyer: "We really like your listing, but honestly we saw a place yesterday on Oak Street that's also in our budget. We're meeting with that agent again tomorrow."

**Flag Output:**
```json
{
  "flag": "competitor_offer_pending",
  "severity": "CRITICAL",
  "quote": "we saw a place yesterday on Oak Street...",
  "context": "Buyer comparing properties, meeting competitor tomorrow",
  "recommended_action": "Call immediately, reinforce unique value, discuss offer strategy"
}
```

---

## CRITICAL: Emotional Peak (`emotional_peak`)

### Definition
Buyer expresses strong positive emotion about the property, indicating maximum buying intent that should be captured immediately.

### Detection Phrases
- "We love it"
- "This is the one"
- "I can see us living here"
- "This feels like home"
- "We don't need to see anything else"
- "When can we make an offer?"

### Severity: CRITICAL
### Response Window: Immediate (strike while hot)

### Required Action
Agent should:
1. Acknowledge and reinforce their feelings
2. Transition to next steps immediately
3. Discuss offer strategy while enthusiasm is high
4. Schedule follow-up within 24 hours maximum

...
```

---

# Pipeline 3: AGENT-COACH (Performance Analysis)

## Purpose
Evaluate agent sales behaviors against best practices and generate coaching recommendations.

## Pipeline Architecture (5 Steps) - Mirrors ENRO

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                           AGENT-COACH PIPELINE                                       │
└─────────────────────────────────────────────────────────────────────────────────────┘

Step 1: CALL OUTCOME CLASSIFICATION (LLM)
├── Classify: appointment_set | offer_submitted | showing_completed | no_progress | lost_lead

Step 2: FILTER HIGH-VALUE CALLS (Python)
├── Keep calls with outcomes worth coaching on
├── Sample across outcome types for balanced training

Step 3: BEHAVIOR OPPORTUNITY IDENTIFICATION (LLM - 3+1 nodes)
┌────────────────────────────────────────────────────────────────────────────────────┐
│  Prompt-input: agent-behaviors-definition.txt                                       │
│                                                                                     │
│  Behavior Categories (adapted from ENRO closing behaviors):                         │
│  ├── needs_discovery              (asking about buyer requirements)                │
│  ├── rapport_building             (personal connection, active listening)          │
│  ├── property_value_articulation  (highlighting unique features)                   │
│  ├── objection_handling           (addressing concerns effectively)                │
│  ├── urgency_creation             (motivating action without pressure)             │
│  ├── next_steps_closing           (securing commitments for follow-up)             │
│  └── competitor_differentiation   (positioning against other agents/properties)    │
│                                                                                     │
│  Each behavior scored 1-5 with:                                                     │
│  ├── What agent did well (quote + explanation)                                     │
│  ├── Missed opportunity (what could have been said)                                │
│  └── Improvement recommendation                                                     │
└────────────────────────────────────────────────────────────────────────────────────┘

Step 4: AGGREGATE & ANNOTATE (Python)
├── Calculate agent-level statistics
├── Identify patterns across calls
├── Rank agents by behavior scores

Step 5: COACHING REPORT GENERATION (LLM - 9 nodes)
├── Multi-stage analysis (like ENRO causal analysis)
├── Generate personalized coaching recommendations
├── Identify top 3 improvement areas per agent
├── Provide specific scripts/phrases to use
```

## Prompt Input: `agent-behaviors-definition.txt` (excerpt)

```markdown
# Agent Sales Behaviors - Scoring Definition

## 1. Needs Discovery (`needs_discovery`)

### Definition
Agent asks probing questions to understand buyer's true requirements, motivations, and constraints before presenting solutions.

### Gold Standard Behavior
Agent should ask open-ended questions about:
- Why they're moving (motivation)
- What they need vs. want (must-haves vs. nice-to-haves)
- Timeline and urgency
- Budget and financing status
- Decision-making process (who else is involved)

### Scoring Rubric
| Score | Criteria |
|-------|----------|
| 5 | Comprehensive discovery: asks about motivation, needs, timeline, budget, decision process. Listens actively, asks follow-ups. |
| 4 | Good discovery: covers 4 of 5 areas, asks follow-up questions |
| 3 | Basic discovery: asks about budget and bedrooms, limited depth |
| 2 | Minimal discovery: jumps to showing properties without understanding needs |
| 1 | No discovery: immediately pitches properties without any questions |

### Example (Score 5)
> Agent: "Before I show you some options, I'd love to understand what's driving your move. What's happening in your life that's making now the right time?"
> Buyer: "We just had our second child and we've outgrown our condo."
> Agent: "Congratulations! So you're looking for more space. Tell me about your ideal setup - what does your family need in terms of bedrooms, outdoor space, proximity to schools?"

### Example (Score 2)
> Agent: "Great, so you're looking for a 3-bedroom. I've got a few listings. Let me send you some links."

### Missed Opportunity Indicators
- Agent talks more than buyer in first 5 minutes
- Agent presents properties before asking about needs
- Agent makes assumptions without confirming

---

## 2. Objection Handling (`objection_handling`)

### Definition
Agent acknowledges buyer concerns without defensiveness and provides relevant information to address them.

### Core Principles (from OBJE pipeline)
1. **ACKNOWLEDGE** - Validate the concern before responding
2. **CLARIFY** - Ask questions to understand the real issue
3. **RESPOND** - Provide specific, relevant information
4. **CONFIRM** - Check if the concern is resolved

### Common Real Estate Objections
| Objection | Good Response Pattern |
|-----------|----------------------|
| "It's too expensive" | Acknowledge → Ask about budget flexibility → Discuss value/comparable sales → Explore financing options |
| "We need to think about it" | Acknowledge → Ask what specifically they need to think about → Address those concerns → Set follow-up |
| "The kitchen is too small" | Acknowledge → Reframe (or suggest renovation budget) → Show comparable with larger kitchen |
| "The commute is too long" | Acknowledge → Discuss flexible work → Highlight other benefits → Ask about deal-breakers |

### Scoring Rubric
| Score | Criteria |
|-------|----------|
| 5 | Acknowledges, clarifies, responds with specifics, confirms resolution. Turns objection into opportunity. |
| 4 | Good handling: acknowledges and provides relevant response, minor gaps |
| 3 | Adequate: addresses objection but defensively or incompletely |
| 2 | Poor: dismisses concern or provides irrelevant response |
| 1 | Harmful: argues with buyer, creates more resistance |

...
```

---

# Pipeline 4: BUYER-JOURNEY (Stage Classification)

## Purpose
Track where each buyer is in their purchase journey to enable stage-appropriate follow-up strategies.

## Pipeline Architecture (2 Steps)

```
Step 1: JOURNEY STAGE CLASSIFICATION (LLM - 5 nodes)
┌────────────────────────────────────────────────────────────────────────────────────┐
│  Stages (with typical behaviors and appropriate agent response):                    │
│                                                                                     │
│  1. AWARENESS                                                                       │
│     Behaviors: "Just started looking", browsing, gathering info                    │
│     Agent Strategy: Educate, nurture, don't push                                   │
│                                                                                     │
│  2. CONSIDERATION                                                                   │
│     Behaviors: Viewing properties, comparing options, asking questions             │
│     Agent Strategy: Qualify needs, show relevant properties                        │
│                                                                                     │
│  3. DECISION                                                                        │
│     Behaviors: Narrowed to 1-2 properties, discussing terms, serious questions     │
│     Agent Strategy: Handle objections, discuss offer strategy                      │
│                                                                                     │
│  4. ACTION                                                                          │
│     Behaviors: Ready to make offer, discussing price, timeline                     │
│     Agent Strategy: Guide through offer process, negotiate                         │
│                                                                                     │
│  5. STALLED                                                                         │
│     Behaviors: Was active, now unresponsive or making excuses                      │
│     Agent Strategy: Re-engagement campaign, identify blockers                      │
└────────────────────────────────────────────────────────────────────────────────────┘

Step 2: JOURNEY ANALYTICS (Python)
├── Track stage progression over time
├── Identify stalled leads for re-engagement
├── Calculate conversion rates by stage
├── Segment leads for targeted campaigns
```

---

# Pipeline 5: OBJECTION-MAP (Objection Tracking)

## Purpose
Catalog objections raised across all calls to identify market trends, training needs, and develop counter-scripts.

## Pipeline Architecture (3 Steps)

```
Step 1: OBJECTION EXTRACTION (LLM - 3+1 nodes)
┌────────────────────────────────────────────────────────────────────────────────────┐
│  Prompt-input: real-estate-objections-definition.txt                               │
│                                                                                     │
│  Objection Categories:                                                              │
│  ├── PRICE                                                                         │
│  │   ├── asking_price_too_high                                                     │
│  │   ├── budget_mismatch                                                           │
│  │   └── value_not_justified                                                       │
│  │                                                                                 │
│  ├── PROPERTY                                                                      │
│  │   ├── size_layout_issues                                                        │
│  │   ├── condition_concerns                                                        │
│  │   ├── location_drawbacks                                                        │
│  │   └── missing_features                                                          │
│  │                                                                                 │
│  ├── TIMING                                                                        │
│  │   ├── not_ready_to_buy                                                          │
│  │   ├── waiting_for_market_change                                                 │
│  │   └── pending_life_event                                                        │
│  │                                                                                 │
│  ├── COMPETITION                                                                   │
│  │   ├── other_property_preferred                                                  │
│  │   ├── other_agent_relationship                                                  │
│  │   └── wants_to_keep_looking                                                     │
│  │                                                                                 │
│  └── TRUST                                                                         │
│       ├── skeptical_of_agent                                                       │
│       ├── past_bad_experience                                                      │
│       └── needs_third_party_validation                                             │
│                                                                                     │
│  Output per objection:                                                              │
│  ├── category + sub_category                                                       │
│  ├── buyer_quote (exact words)                                                     │
│  ├── agent_response (what agent said)                                              │
│  ├── response_effectiveness (1-5)                                                  │
│  └── resolution_status (resolved | partially_resolved | unresolved)                │
└────────────────────────────────────────────────────────────────────────────────────┘

Step 2: OBJECTION ANALYTICS (Python)
├── Frequency by category (what objections are most common?)
├── Resolution rates by category (which are hardest to overcome?)
├── Agent performance by objection type
├── Property-specific objection patterns

Step 3: COUNTER-SCRIPT GENERATION (LLM)
├── Generate best-practice responses for common objections
├── Include successful agent responses as examples
├── Create training materials
```

---

# Pipeline 6: PROPERTY-MATCH (Buyer-Property Fit)

## Purpose
Analyze how well properties match buyer stated preferences and identify mismatches to address.

## Pipeline Architecture (2 Steps)

```
Step 1: PREFERENCE EXTRACTION (LLM)
├── Extract stated buyer preferences from call
├── Categories: location, size, features, budget, style, schools, commute

Step 2: MATCH ANALYSIS (LLM + Python)
├── Compare stated preferences to property being discussed
├── Identify matches, mismatches, and unstated preferences revealed
├── Suggest better-fit properties from inventory
├── Flag when buyer is being shown wrong properties
```

---

# Implementation Priority Recommendation

## Phase 1: Quick Wins (Week 1-2)
1. **LEAD-SCORE Step 1** - Buyer intent classification (highest immediate value)
2. **URGENT-FLAG** - Immediate action alerts (prevents lost deals)

## Phase 2: Core Analytics (Week 3-4)
3. **LEAD-SCORE Steps 2-4** - Full lead scoring with positive/negative signals
4. **BUYER-JOURNEY** - Stage tracking for better follow-up

## Phase 3: Performance Optimization (Week 5-6)
5. **AGENT-COACH** - Agent performance and coaching
6. **OBJECTION-MAP** - Objection tracking and counter-scripts

## Phase 4: Advanced (Week 7+)
7. **PROPERTY-MATCH** - Property-buyer fit analysis

---

# Taxonomy Files Needed

Based on the `andre-taxonomy` collections, I recommend creating these real estate taxonomies:

## Buyer Behavior Taxonomies
- `buyer-readiness-taxonomy.txt` - Based on `readiness-taxonomy.txt`
- `buyer-emotion-taxonomy.txt` - Based on `emotion-taxonomy.txt`
- `buyer-decision-taxonomy.txt` - Based on `decision-taxonomy.txt`
- `buyer-motivation-taxonomy.txt` - Based on `motivation-taxonomy.txt`

## Agent Behavior Taxonomies
- `agent-communication-taxonomy.txt` - Based on `communication-taxonomy.txt`
- `agent-listening-taxonomy.txt` - Based on `listening-taxonomy.txt`
- `agent-closing-taxonomy.txt` - Based on `closing-taxonomy.txt`
- `agent-objection-taxonomy.txt` - Based on `objection-taxonomy.txt`

## Interaction Taxonomies
- `call-progression-taxonomy.txt` - Based on `progression-taxonomy.txt`
- `rapport-collaborative-taxonomy.txt` - Based on `collaborative-taxonomy.txt`

---

# Sample Output: Lead Score Report

```json
{
  "lead_id": "CALL-2024-12345",
  "buyer_name": "John & Sarah Smith",
  "agent": "Mike Johnson",
  "call_date": "2024-12-03",

  "lead_score": 82,
  "tier": "HOT",

  "classification": {
    "buyer_stage": "READY_TO_OFFER",
    "timeline": "IMMEDIATE",
    "financing_status": "PRE_APPROVED",
    "motivation_level": "HIGH"
  },

  "positive_signals": [
    {
      "category": "financial_readiness",
      "score": 5,
      "quote": "We got pre-approved for $650k last week",
      "weight_contribution": 15
    },
    {
      "category": "timeline_urgency",
      "score": 5,
      "quote": "Our lease ends February 1st, we have to be out",
      "weight_contribution": 15
    },
    {
      "category": "commitment_language",
      "score": 4,
      "quote": "This house checks all our boxes",
      "weight_contribution": 10
    }
  ],

  "negative_signals": [
    {
      "category": "competitor_preference",
      "severity": 3,
      "quote": "We did see one other place we liked on Maple Street",
      "weight_deduction": 8
    }
  ],

  "recommended_actions": [
    "Schedule second showing within 48 hours",
    "Prepare offer strategy discussion",
    "Address competitor property - highlight unique advantages"
  ],

  "urgency_flags": [
    {
      "flag": "competitor_offer_pending",
      "severity": "HIGH",
      "action": "Follow up today about their interest level vs Maple St property"
    }
  ]
}
```

---

*Generated: December 3, 2025*
*Based on OES LLM Processor patterns*
