#!/usr/bin/env bash

# Step 2: Analyze property-buyer match (Python + LLM)

uv run real-estate-property-match \
    --start-date {{START_DATE}} \
    --inventory-file "${PROPERTY_INVENTORY_PATH}"

# Analysis:
#   - Compare stated preferences to property being discussed
#   - Identify matches, mismatches, and unstated preferences
#   - Suggest better-fit properties from inventory
#   - Flag when buyer is being shown wrong properties
#
# Outputs:
#   - property-match/week-{N}/match_analysis.json
#   - property-match/week-{N}/mismatch_alerts.json (buyer shown wrong properties)
#   - property-match/week-{N}/better_fits.json (alternative suggestions)
#   - property-match/week-{N}/preference_gaps.json (unstated preferences revealed)
