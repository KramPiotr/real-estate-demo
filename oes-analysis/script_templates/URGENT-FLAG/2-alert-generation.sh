#!/usr/bin/env bash

# Step 2: Generate alerts from urgency flags (Python)
# Routes alerts by severity to appropriate channels

uv run real-estate-urgent-alerts \
    --start-date {{START_DATE}} \
    --slack-webhook "${SLACK_WEBHOOK_URL}" \
    --email-alerts

# Inputs:
#   - partial_results/urgency-detection-1__week-{N}/
#
# Actions by Severity:
#   CRITICAL → Slack/SMS alert to agent + manager (immediate)
#   HIGH → Email alert + CRM task (within 2 hours)
#   MEDIUM → Daily digest + CRM task (within 24 hours)
#
# Outputs:
#   - urgent-alerts/week-{N}/alerts.json
#   - urgent-alerts/week-{N}/urgent_calls_report.html
#   - CRM webhook payloads (if configured)

echo ""
echo "Alert Routing:"
echo "  - CRITICAL: Immediate Slack/SMS notification"
echo "  - HIGH: Email within 2 hours"
echo "  - MEDIUM: Daily digest"
