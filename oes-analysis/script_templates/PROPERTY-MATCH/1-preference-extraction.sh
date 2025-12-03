#!/usr/bin/env bash

# Step 1: Extract buyer preferences from calls
# Uses 3+1 node architecture

uv run multi-agent-batch \
    -c preference-extraction-1 \
    -sm s3 \
    -t "{{START_DATE}}-{{END_DATE}}" \
    -f "over-2-mins" \
    -e east-us \
    -pi property-preferences \
    -l gemini \
    -ss "{{WEEK_ID}}" \
    -s \
    -p

# Prompt input: property-preferences-definition.txt
# Preference Categories:
#   - location: neighborhoods, commute requirements, school districts
#   - size: bedrooms, bathrooms, square footage, lot size
#   - features: must-haves vs nice-to-haves, deal-breakers
#   - budget: price range, flexibility, financing approach
#   - style: architecture, age, condition tolerance
#   - lifestyle: family needs, pets, work-from-home, entertaining
#
# Output: partial_results/preference-extraction-1__week-{N}/
