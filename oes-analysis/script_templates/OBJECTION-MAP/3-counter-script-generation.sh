#!/usr/bin/env bash

# Step 3: Generate counter-scripts for common objections (LLM)

uv run multi-agent-batch \
    -c counter-script-generation-1 \
    -sm s3 \
    -t "objection-analytics/week-{{WEEK_ID}}" \
    -e west-us \
    -l gemini \
    -ss "{{WEEK_ID}}-scripts" \
    -s \
    -p

# Generates:
#   - Best-practice responses for common objections
#   - Includes successful agent responses as examples
#   - Creates training materials with scripts
#
# Output: partial_results/counter-script-generation-1__week-{N}/
#   - counter_scripts.json (organized by objection category)
#   - training_materials.md (formatted for agent training)
