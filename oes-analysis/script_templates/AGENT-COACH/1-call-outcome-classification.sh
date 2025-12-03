#!/usr/bin/env bash

# Step 1: Classify call outcomes
# Uses 5 mini models for consensus-based classification

uv run multi-agent-batch \
    -c call-outcome-classification-1 \
    -s \
    -p \
    -sm s3 \
    -t "{{START_DATE}}-{{END_DATE}}" \
    -f "over-2-mins" \
    -l gemini \
    -e west-us \
    -ss "{{WEEK_ID}}"

# Outcome Categories:
#   - APPOINTMENT_SET: Viewing or meeting scheduled
#   - OFFER_SUBMITTED: Buyer made or discussed making offer
#   - SHOWING_COMPLETED: Post-viewing follow-up call
#   - NO_PROGRESS: Call without advancement
#   - LOST_LEAD: Buyer disengaged or chose competitor
#
# Output: partial_results/call-outcome-classification-1__week-{N}/
