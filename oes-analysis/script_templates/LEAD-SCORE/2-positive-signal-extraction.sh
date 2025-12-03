#!/usr/bin/env bash

# Step 2: Extract positive buyer signals
# Uses 3+1 node architecture (3 independent + 1 aggregation)

uv run multi-agent-batch \
    -c buyer-signals-positive-1 \
    -sm s3 \
    -t "{{START_DATE}}-{{END_DATE}}" \
    -f "over-2-mins" \
    -e east-us \
    -pi positive-signals \
    -l gemini \
    -ss "{{WEEK_ID}}" \
    -s \
    -p

# Prompt input: positive-signals-definition.txt
# Categories: financial_readiness, timeline_urgency, decision_maker_engagement,
#             property_specificity, repeat_engagement, commitment_language
# Output: partial_results/buyer-signals-positive-1__week-{N}/
