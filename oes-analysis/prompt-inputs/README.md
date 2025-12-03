# Prompt Inputs Directory - README

## Overview

This directory contains structured prompt definitions, taxonomies, and evaluation frameworks that power the Sales AI Analysis System for university enrollment calls. The system analyzes consultant behaviors, student patterns, compliance requirements, and causal relationships between actions and outcomes.

**Total Resources**: 232+ files across 30 directories
**Main Format**: Text files (.txt) with structured JSON taxonomies
**Coverage**: 139 behavioral features (67 sales, 72 student) across 16 categories

## Quick Start

### What to Use When

| Need | Directory | Key File |
|------|-----------|----------|
| Define a sales behavior | `behavioural_definitions/` | `{behavior}-definition.txt` |
| Identify opportunities | `causals/` | `{behavior}v5-opportunity.txt` |
| Check compliance | `all_compliance/` | `{requirement}-enhanced.txt` |
| Extract features | `taxonomy-structured-files/` | `master_taxonomy_comprehensive.json` |
| Evaluate quality | `evals/` | `CLEA-criteria.txt` |
| Best practices | `best_practice_consultation/` | `combined_best_practice.txt` |

### Most Commonly Used Directories

1. **`causals/`** - Causal opportunity definitions (use v5 versions)
2. **`taxonomy-structured-files/`** - 139 features in JSON format
3. **`all_compliance/`** - Current compliance requirements
4. **`evals/`** - Quality evaluation standards
5. **`ground-truth-data-new/`** - Ground truth for model training

## Directory Organization

The repository is organized into 9 logical groups:

### GROUP 1: Behavioral Definitions
Basic consultant behavior definitions
- `behavioural_definitions/` - Individual definitions
- `behavioural_definitions_combined/` - All in one file

### GROUP 2: Best Practice & Compliance
Compliance requirements and best practice guides
- `all_compliance/` - **CURRENT** compliance standards
- `best_practice_consultation/` - Consultation best practices
- `compliance_archive/` - Historical (archive only)

### GROUP 3: Causal Analysis
Opportunity-based behavior definitions with scoring
- `causals/` - **PRIMARY** causal definitions
  - Use v5 versions when available
  - Files paired: `-definition.txt` + `-opportunity.txt`

### GROUP 4: Factor Analysis
Two-factor models (student need + consultant performance)
- `factor_definitions/` - Factor-based predictive models

### GROUP 5: Taxonomy Systems
Complete feature extraction framework (139 features)
- `taxonomy-structured-files/` - **RECOMMENDED** JSON format
- `andre-taxonomy-combined/` - Complete text format
- `andre-taxonomy-sales/` - Sales consultant features only
- `andre-taxonomy-student/` - Student features only

### GROUP 6: Start Taxonomy & Specialized
Call structure and specialized assessments
- `start-taxonomy/` - Communication effectiveness
- `student-ops-*/` - Student operations specific

### GROUP 7: Ground Truth Data
Reference data for training and validation
- `ground-truth-data-new/` - **CURRENT** ground truth
- `OLD-ground-truth-data-OLD/` - Deprecated (do not use)

### GROUP 8: Evaluation & Configuration
Quality criteria and training scenarios
- `evals/` - CLEA evaluation criteria
- `scenes-config/` - Training scenario configs

### GROUP 9: Archive
Historical versions and experiments
- `archive/` - Experimental features (reference only)

## Key Concepts

### Behavioral vs Causal Definitions
- **Behavioral** (`behavioural_definitions/`): Basic behavior descriptions
- **Causal** (`causals/`): Include opportunity identification, scoring rubrics (1-5), causal impact logic

### Broad vs Enhanced
- **Broad**: General, flexible interpretation
- **Enhanced**: Detailed, strict regulatory compliance

### Sales vs Student Features
- **Sales** (67 features): Consultant behaviors and techniques
- **Student** (72 features): Student characteristics and patterns

## Version Control

### Active Versions (Use These)

**Causal Behaviors:**
- Communication: `communication2-opportunity.txt`
- Closing: `closingv5-opportunity.txt`
- Objection: `objection3-opportunity.txt`
- Listening: `listening2-opportunity.txt`

**Compliance:**
- Current: `all_compliance/`

**Ground Truth:**
- Active: `ground-truth-data-new/`

**Taxonomy:**
- JSON: `taxonomy-structured-files/master_taxonomy_comprehensive.json`
- Text: `andre-taxonomy-combined/`

### Archived Versions (Reference Only)
- `compliance_archive/`
- `causals/archive/`
- `OLD-ground-truth-data-OLD/`
- `archive/`

### Version Indicators
- `v2, v3, v4, v5` - Higher number = newer
- `old, old2` - Explicitly deprecated
- No suffix - Original or actively maintained

## Taxonomy System Details

### 139 Features Across 16 Categories

**Sales Consultant (67 features, 48.2%)**
1. Expectation Setting & Information Accuracy
3. Sales Consultant Behaviors
5. Progression Enablers & Barriers
12. Enrollment Closing Behavioral Patterns
13. Communication & Expertise Behavioral Patterns
14. Objection Handling Behavioral Patterns
15. Active Listening Behavioral Patterns
16. Collaborative Planning Behavioral Patterns

**Student (72 features, 51.8%)**
2. Student Readiness Indicators
4. Student Linguistic & Emotional Patterns
6. Demographic & Life Context Indicators
7. Academic Background & Learning Readiness
8. Communication Patterns & Engagement Quality
9. Motivation Quality & Goal Sophistication
10. Support System & Resource Availability
11. Decision-Making Process & Commitment Indicators

### Accessing Taxonomy Data

**Python (JSON format)**
```python
import json

# Load complete taxonomy
with open('taxonomy-structured-files/master_taxonomy_comprehensive.json', 'r') as f:
    taxonomy = json.load(f)

# Get all features
all_features = taxonomy['all_features']  # 139 features

# Filter by type
sales = [f for f in all_features if f['type'] == 'sales']
student = [f for f in all_features if f['type'] == 'student']

# Filter by category
category_13 = taxonomy['categories']['13']  # Communication & Expertise
```

**Text format**
- Use `andre-taxonomy-combined/` for complete set
- Use specialized directories (`andre-taxonomy-sales/`, `andre-taxonomy-student/`) for focused analysis

## Common Workflows

### 1. Behavioral Analysis
```
Input: Transcript
Use: behavioural_definitions/ OR causals/
Output: Identified behaviors with examples
```

### 2. Causal Analysis
```
Input: Transcript
Use: causals/{behavior}v5-opportunity.txt
Process:
  1. Identify opportunities (student signals)
  2. Score opportunity strength (1-5)
  3. Analyze consultant response
  4. Assess causal impact
Output: Scored opportunities + response analysis
```

### 3. Compliance Checking
```
Input: Transcript
Use: all_compliance/{requirement}-enhanced.txt
Process: Check each requirement is met
Output: Compliance report
```

### 4. Feature Extraction
```
Input: Transcript
Use: taxonomy-structured-files/master_taxonomy_comprehensive.json
Process: Extract all 139 features
Output: Feature vector for ML model
```

### 5. Quality Evaluation
```
Input: AI-generated analysis
Use: evals/CLEA-criteria.txt
Process: Apply evaluation criteria
Output: Quality score + feedback
```

## File Formats

### Behavioral Definition (XML-like)
```xml
<behavior_specific>
  <behavior_name>Empathy</behavior_name>
  <behavior_definition>Showing understanding...</behavior_definition>
  <behavior_essence>Putting oneself in student's shoes...</behavior_essence>
  <behavior_examples>
    * "I understand how challenging..."
  </behavior_examples>
</behavior_specific>
```

### Causal Opportunity (Markdown with tags)
```markdown
# Behavior: Opportunity Definition

<opportunity_definition>
An opportunity occurs when...
</opportunity_definition>

<scoring_rubric>
5 - Critical: ...
4 - Strong: ...
3 - Moderate: ...
2 - Low: ...
1 - Minimal: ...
</scoring_rubric>

<good_examples>
Example with explanation...
</good_examples>
```

### Taxonomy (Hierarchical text)
```markdown
## CATEGORY: Communication & Expertise

### 13.A: Eligibility Communication
**13.A.i: Clear Requirements Explanation**
Description: Consultant clearly explains...
Identification Guidance: Look for...
Examples:
- "To qualify, you need..."
```

### Taxonomy (JSON)
```json
{
  "index": "13.A.i",
  "title": "Clear Requirements Explanation",
  "type": "sales",
  "description": "Consultant clearly explains...",
  "identification_guidance": "Look for...",
  "examples": ["To qualify, you need..."],
  "section_index": "13.A",
  "section_title": "Eligibility Communication"
}
```

## Best Practices

### 1. Always Use Latest Versions
Check version numbers (v5 > v4 > v3) and use the highest available.

### 2. Prefer Combined Files
When available (e.g., `combined_best_practice.txt`), use combined files for efficiency.

### 3. Use JSON for Automation
For scripts and ML, use `taxonomy-structured-files/` instead of text files.

### 4. Check Archives First
Before creating new content, verify it doesn't exist in archive directories.

### 5. Reference Evaluation Criteria
Use `evals/CLEA-criteria.txt` to ensure analysis quality standards.

### 6. Understand Causal Impact
When using `causals/`, always read the causal impact logic section to understand why each behavior matters.

### 7. Match Compliance Variant to Use Case
- Use `-broad.txt` for general guidance
- Use `-enhanced.txt` for strict regulatory compliance

## Integration with Multi-Agent System

This directory feeds into the multi-agent batch processing system:

```
prompt-inputs/
    ↓
multi_agent_configuration/*.json
    ↓
multi_agent_batch/main.py
    ↓
Analysis Results
```

**Configuration files** specify which prompt files to use for each analysis node.

**Analysis types** reference different directory groups:
- Behavioral Analysis → GROUP 1
- Causal Analysis → GROUP 3
- Compliance Analysis → GROUP 2
- Feature Extraction → GROUP 5
- Factor Analysis → GROUP 4

## Maintenance Notes

### Active Development Areas
1. Causal Analysis (v5 versions, special cases)
2. Taxonomy Structuring (recent JSON conversion)
3. Compliance Standards (ongoing updates)

### Stable/Mature Areas
1. Behavioral definitions (well-established)
2. Compliance archive (historical only)
3. OLD ground truth data (deprecated)

### Recommendations
1. **Consolidate** best_practice directories (3 similar directories)
2. **Archive** older causal versions (v1, v2) to causals/archive/
3. **Document** difference between broad/enhanced variants
4. **Add** README files in each major directory group
5. **Consider** consolidating student-ops-* directories

## Documentation

- **DIRECTORY_ANALYSIS.md** - Complete detailed analysis (15,000+ words)
- **DIRECTORY_QUICK_REFERENCE.md** - Quick lookup tables and guides
- **DIRECTORY_MAP.txt** - Visual ASCII directory tree map
- **README.md** - This file (overview and getting started)

## Statistics

| Metric | Count |
|--------|-------|
| Total Directories | 30 |
| Total Files | 232+ |
| Behavioral Definitions | 17 |
| Causal Opportunities | 52 |
| Compliance Standards | 59 |
| Taxonomy Features | 139 |
| Sales Features | 67 (48.2%) |
| Student Features | 72 (51.8%) |
| Taxonomy Categories | 16 |
| Factor Definitions | 7 |
| Ground Truth Files | 24 |

## Support

For questions about specific directories or files, consult:
1. **This README** for overview and quick start
2. **DIRECTORY_QUICK_REFERENCE.md** for quick lookup
3. **DIRECTORY_ANALYSIS.md** for comprehensive details
4. **Individual README files** in subdirectories (e.g., taxonomy-structured-files/README.md)
5. **Project documentation** at ../CLAUDE.md

## License & Usage

This directory is part of the OES Sales AI Analysis System. All content is proprietary and for internal use only.

---

**Last Updated**: 2025-10-08
**Maintained by**: Sales AI Analysis Team
**Repository**: /mnt/efs/oes_cxone_call_recordings/sentiment-ai/oes-sales-piotr/prompt-inputs/
