#!/usr/bin/env bash

# Step 4: Aggregate scores and annotate transcripts (Python)

uv run real-estate-aggregate-coaching \
    --start-date {{START_DATE}} \
    --workers 12

# Processing:
#   - Filter for high-scoring opportunities (score >= 4) and low-scoring (score <= 2)
#   - Calculate agent-level statistics
#   - Identify patterns across calls
#   - Rank agents by behavior scores
#
# Outputs:
#   - transcripts/weekly-analysis-{date}-COACH-annotated/
#       ├── needs-discovery/
#       ├── rapport-building/
#       ├── property-value-articulation/
#       ├── objection-handling/
#       ├── urgency-creation/
#       ├── next-steps-closing/
#       └── competitor-differentiation/
#   - coaching-aggregation/week-{N}/
#       ├── agent_statistics.json
#       └── behavior_breakdown.json
