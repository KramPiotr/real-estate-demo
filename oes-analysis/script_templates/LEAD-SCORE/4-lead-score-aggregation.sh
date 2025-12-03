#!/usr/bin/env bash

# Step 4: Aggregate all signals into lead scores (Python)
# Combines: intent classification + positive signals + negative signals

uv run real-estate-lead-score \
    --start-date {{START_DATE}} \
    --workers 12

# Inputs:
#   - partial_results/buyer-intent-classification-1__week-{N}/
#   - partial_results/buyer-signals-positive-1__week-{N}/
#   - partial_results/buyer-signals-negative-1__week-{N}/
#
# Outputs:
#   - lead-scores/week-{N}/lead_scores.json (prioritized list)
#   - lead-scores/week-{N}/hot_leads.json (score > 80)
#   - lead-scores/week-{N}/lead_breakdown.json (per-lead details)

echo ""
echo "Lead Score Tiers:"
echo "  - HOT (80-100): Immediate follow-up required"
echo "  - WARM (60-79): Follow up within 24 hours"
echo "  - COOL (40-59): Weekly nurture sequence"
echo "  - COLD (0-39): Monthly check-in"
