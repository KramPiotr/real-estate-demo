#!/usr/bin/env bash

# Step 3: Extract negative buyer signals
# Uses 3+1 node architecture (3 independent + 1 aggregation)

uv run multi-agent-batch \
    -c buyer-signals-negative-1 \
    -sm s3 \
    -t "{{START_DATE}}-{{END_DATE}}" \
    -f "over-2-mins" \
    -e east-us \
    -pi negative-signals \
    -l gemini \
    -ss "{{WEEK_ID}}" \
    -s \
    -p

# Prompt input: negative-signals-definition.txt
# Categories: financial_barriers, decision_paralysis, external_blockers,
#             unrealistic_expectations, competitor_preference, disengagement_signals
# Output: partial_results/buyer-signals-negative-1__week-{N}/
