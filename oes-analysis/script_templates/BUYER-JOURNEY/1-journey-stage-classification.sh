#!/usr/bin/env bash

# Step 1: Classify buyer journey stage
# Uses 5 mini models for consensus

uv run multi-agent-batch \
    -c buyer-journey-classification-1 \
    -s \
    -p \
    -sm s3 \
    -t "{{START_DATE}}-{{END_DATE}}" \
    -f "over-2-mins" \
    -l gemini \
    -e west-us \
    -ss "{{WEEK_ID}}"

# Journey Stages:
#   1. AWARENESS: Just started looking, gathering info
#   2. CONSIDERATION: Viewing properties, comparing options
#   3. DECISION: Narrowed to 1-2 properties, serious questions
#   4. ACTION: Ready to make offer, discussing price/terms
#   5. STALLED: Was active, now unresponsive or making excuses
#
# Output: partial_results/buyer-journey-classification-1__week-{N}/
