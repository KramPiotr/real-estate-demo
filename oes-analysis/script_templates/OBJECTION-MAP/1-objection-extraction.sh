#!/usr/bin/env bash

# Step 1: Extract objections from calls
# Uses 3+1 node architecture

uv run multi-agent-batch \
    -c objection-extraction-1 \
    -sm s3 \
    -t "{{START_DATE}}-{{END_DATE}}" \
    -f "over-2-mins" \
    -e east-us \
    -pi real-estate-objections \
    -l gemini \
    -ss "{{WEEK_ID}}" \
    -s \
    -p

# Prompt input: real-estate-objections-definition.txt
# Objection Categories:
#   PRICE: asking_price_too_high, budget_mismatch, value_not_justified
#   PROPERTY: size_layout_issues, condition_concerns, location_drawbacks, missing_features
#   TIMING: not_ready_to_buy, waiting_for_market_change, pending_life_event
#   COMPETITION: other_property_preferred, other_agent_relationship, wants_to_keep_looking
#   TRUST: skeptical_of_agent, past_bad_experience, needs_third_party_validation
#
# Per objection: category, buyer_quote, agent_response, response_effectiveness (1-5), resolution_status
# Output: partial_results/objection-extraction-1__week-{N}/
