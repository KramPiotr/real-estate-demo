#!/usr/bin/env bash

# Step 2: Filter calls worth coaching on (Python)
# Samples across outcome types for balanced training data

uv run real-estate-filter-coaching-calls \
    --start-date {{START_DATE}} \
    -t "{{START_DATE}}-{{END_DATE}}"

# Filtering Logic:
#   - Keep all OFFER_SUBMITTED calls (learn from success)
#   - Keep all LOST_LEAD calls (learn from failure)
#   - Sample APPOINTMENT_SET calls (good progression)
#   - Sample NO_PROGRESS calls (improvement opportunities)
#
# Output: transcripts/weekly-analysis-{date}-coaching-eligible/
