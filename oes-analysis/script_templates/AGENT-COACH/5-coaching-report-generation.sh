#!/usr/bin/env bash

# Step 5: Generate coaching reports (LLM - 9 nodes)
# Multi-stage analysis for comprehensive coaching recommendations

uv run multi-agent-batch \
    -c coaching-report-generation-1 \
    -sm s3 \
    -t "{{START_DATE}}-{{END_DATE}}-COACH-annotated" \
    -pi "agent-behaviors" \
    -e west-us \
    -l gemini \
    -ss "{{WEEK_ID}}-COACH-annotated" \
    -f "over-2-mins" \
    -s \
    -p

# Multi-stage nodes:
#   1. behavior_analysis: Evaluate each behavior category
#   2. strength_identification: What agent does well
#   3. weakness_identification: Areas needing improvement
#   4. pattern_recognition: Recurring issues across calls
#   5. script_suggestion: Specific phrases to use
#   6. priority_ranking: Top 3 improvement areas
#   7. action_plan: Concrete steps for improvement
#   8. validation: Cross-check recommendations
#   9. condense_report: Final coaching summary
#
# Output: partial_results/coaching-report-generation-1__week-{N}/
