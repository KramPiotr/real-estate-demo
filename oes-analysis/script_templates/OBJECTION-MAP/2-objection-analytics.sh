#!/usr/bin/env bash

# Step 2: Objection analytics (Python)

uv run real-estate-objection-analytics \
    --start-date {{START_DATE}} \
    --workers 12

# Analytics:
#   - Frequency by category (what objections are most common?)
#   - Resolution rates by category (which are hardest to overcome?)
#   - Agent performance by objection type
#   - Property-specific objection patterns
#
# Outputs:
#   - objection-analytics/week-{N}/frequency_by_category.json
#   - objection-analytics/week-{N}/resolution_rates.json
#   - objection-analytics/week-{N}/agent_performance.json
#   - objection-analytics/week-{N}/property_patterns.json
