#!/usr/bin/env bash

# Real Estate Analysis Pipeline - S3 Upload Script
# This script uploads all prompts, prompt inputs, and configs to S3
#
# Usage: ./upload-to-s3.sh [bucket-name] [prefix]
#
# Default bucket: sentiment-ai-mab
# Default prefix: real-estate/

set -e

BUCKET="${1:-sentiment-ai-mab}"
PREFIX="${2:-real-estate/}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Real Estate Analysis - S3 Upload${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "Bucket: ${YELLOW}s3://${BUCKET}${NC}"
echo -e "Prefix: ${YELLOW}${PREFIX}${NC}"
echo ""

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Function to upload a directory
upload_directory() {
    local source_dir="$1"
    local dest_path="$2"
    local description="$3"

    if [ -d "$source_dir" ]; then
        echo -e "${YELLOW}Uploading ${description}...${NC}"
        aws s3 sync "$source_dir" "s3://${BUCKET}/${PREFIX}${dest_path}" --delete
        echo -e "${GREEN}  ✓ ${description} uploaded${NC}"
    else
        echo -e "${RED}  ✗ Directory not found: ${source_dir}${NC}"
    fi
}

# Confirm before upload
echo -e "${YELLOW}This will upload the following to S3:${NC}"
echo "  - real-estate-prompts/ -> s3://${BUCKET}/${PREFIX}prompts/"
echo "  - real-estate-prompt-inputs/ -> s3://${BUCKET}/${PREFIX}prompt-inputs/"
echo "  - real-estate-configs/ -> s3://${BUCKET}/${PREFIX}configs/"
echo ""
read -p "Continue? (y/n) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${RED}Upload cancelled.${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}Starting upload...${NC}"
echo ""

# Upload prompt inputs (definitions)
upload_directory \
    "${SCRIPT_DIR}/real-estate-prompt-inputs" \
    "prompt-inputs/real-estate-definitions" \
    "Prompt Inputs (Definitions)"

# Upload configs
upload_directory \
    "${SCRIPT_DIR}/real-estate-configs" \
    "configs/active" \
    "Config Files"

# Upload prompts
upload_directory \
    "${SCRIPT_DIR}/real-estate-prompts" \
    "prompts" \
    "System/User Prompts"

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Upload Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "Uploaded to: ${YELLOW}s3://${BUCKET}/${PREFIX}${NC}"
echo ""
echo -e "${YELLOW}Verify with:${NC}"
echo "  aws s3 ls s3://${BUCKET}/${PREFIX} --recursive | head -50"
echo ""

# Show what was uploaded
echo -e "${YELLOW}Summary of uploaded content:${NC}"
echo ""

echo "Prompt Inputs:"
find "${SCRIPT_DIR}/real-estate-prompt-inputs" -type f -name "*.txt" 2>/dev/null | wc -l | xargs echo "  - Files:"

echo ""
echo "Configs:"
find "${SCRIPT_DIR}/real-estate-configs" -type f -name "*.json" 2>/dev/null | wc -l | xargs echo "  - Files:"

echo ""
echo "Prompts:"
find "${SCRIPT_DIR}/real-estate-prompts" -type f -name "*.txt" 2>/dev/null | wc -l | xargs echo "  - Files:"

echo ""
echo -e "${GREEN}Done!${NC}"
