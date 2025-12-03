#!/usr/bin/env bash

# Step 1: Detect urgency flags in calls
# Uses 3+1 node architecture for reliable flag detection

uv run multi-agent-batch \
    -c urgency-detection-1 \
    -sm s3 \
    -t "{{START_DATE}}-{{END_DATE}}" \
    -f "over-2-mins" \
    -e east-us \
    -pi urgency-flags \
    -l gemini \
    -ss "{{WEEK_ID}}" \
    -s \
    -p

# Prompt input: urgency-flags-definition.txt
# Flag Severities:
#   CRITICAL: competitor_offer_pending, deadline_today, viewing_with_competitor, emotional_peak
#   HIGH: price_objection_serious, losing_interest, requested_callback, inspection_concern
#   MEDIUM: needs_more_info, wants_second_viewing, financing_question, negotiation_signal
#
# Output: partial_results/urgency-detection-1__week-{N}/
