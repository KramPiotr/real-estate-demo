#!/usr/bin/env bash

# Step 2: Journey stage analytics (Python)

uv run real-estate-journey-analytics \
    --start-date {{START_DATE}}

# Analytics:
#   - Track stage progression over time
#   - Identify stalled leads for re-engagement
#   - Calculate conversion rates by stage
#   - Segment leads for targeted campaigns
#
# Outputs:
#   - journey-analytics/week-{N}/stage_distribution.json
#   - journey-analytics/week-{N}/stalled_leads.json
#   - journey-analytics/week-{N}/conversion_funnel.json
#   - journey-analytics/week-{N}/campaign_segments.json

echo ""
echo "Journey Stage Actions:"
echo "  - AWARENESS: Educate, nurture, don't push"
echo "  - CONSIDERATION: Qualify needs, show relevant properties"
echo "  - DECISION: Handle objections, discuss offer strategy"
echo "  - ACTION: Guide through offer process, negotiate"
echo "  - STALLED: Re-engagement campaign, identify blockers"
