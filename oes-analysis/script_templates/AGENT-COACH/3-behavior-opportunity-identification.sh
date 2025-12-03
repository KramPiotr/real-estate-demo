#!/usr/bin/env bash

# Step 3: Identify agent behavior opportunities
# Uses 3+1 node architecture with behavioral rubrics

uv run multi-agent-batch \
    -c agent-behavior-analysis-1 \
    -sm s3 \
    -t "{{START_DATE}}-{{END_DATE}}-coaching-eligible" \
    -f "over-2-mins" \
    -e east-us \
    -pi agent-behaviors \
    -l gemini \
    -ss "{{WEEK_ID}}-coaching-eligible" \
    -s \
    -p

# Prompt input: agent-behaviors-definition.txt
# Behavior Categories:
#   - needs_discovery: Asking about buyer requirements
#   - rapport_building: Personal connection, active listening
#   - property_value_articulation: Highlighting unique features
#   - objection_handling: Addressing concerns effectively
#   - urgency_creation: Motivating action without pressure
#   - next_steps_closing: Securing commitments for follow-up
#   - competitor_differentiation: Positioning against competition
#
# Each scored 1-5 with quotes and improvement recommendations
# Output: partial_results/agent-behavior-analysis-1__week-{N}/
