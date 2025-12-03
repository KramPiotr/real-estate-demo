#!/usr/bin/env bash

# Step 1: Classify buyer intent and stage
# Uses 5 mini models for consensus-based classification

uv run multi-agent-batch \
    -c buyer-intent-classification-1 \
    -s \
    -p \
    -sm s3 \
    -t "{{START_DATE}}-{{END_DATE}}" \
    -f "over-2-mins" \
    -l gemini \
    -e west-us \
    -ss "{{WEEK_ID}}"

# Output: Classifications for buyer_stage, timeline, financing_status, motivation_level
# Location: partial_results/buyer-intent-classification-1__week-{N}/
