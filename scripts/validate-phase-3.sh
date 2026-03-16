#!/bin/bash

# Phase 03 - Validation Suite

set -e

echo "Running Phase 03 Validation Suite..."

# 03-02-01: Ch 8 Artifacts & Tool Schemas
if grep -q "Tool Schema" chapters/08-*.md; then
    echo "✅ Chapter 8 contains 'Tool Schema'."
else
    echo "⚠️ Chapter 8 does not contain 'Tool Schema'."
fi

if [ -f "artifacts/tool_schemas_A.json" ] && [ -f "artifacts/tool_schemas_B.json" ]; then
    echo "✅ Tool Schemas for A and B exist."
else
    echo "⚠️ Tool Schemas for A and B are missing."
fi

# 03-02-02: Ch 9 Artifacts & Retrieval Maps
if grep -q "Retrieval Map" chapters/09-*.md; then
    echo "✅ Chapter 9 contains 'Retrieval Map'."
else
    echo "⚠️ Chapter 9 does not contain 'Retrieval Map'."
fi

if [ -f "artifacts/retrieval_map_A.md" ] && [ -f "artifacts/retrieval_map_B.md" ]; then
    echo "✅ Retrieval Maps for A and B exist."
else
    echo "⚠️ Retrieval Maps for A and B are missing."
fi

# 03-02-03: Ch 10 Artifacts & Planning Templates
if grep -q "Planning Template" chapters/10-*.md; then
    echo "✅ Chapter 10 contains 'Planning Template'."
else
    echo "⚠️ Chapter 10 does not contain 'Planning Template'."
fi

if [ -f "artifacts/planning_template_A.md" ] && [ -f "artifacts/planning_template_B.md" ]; then
    echo "✅ Planning Templates for A and B exist."
else
    echo "⚠️ Planning Templates for A and B are missing."
fi

# 03-02-04: Ch 11 Artifacts & State Models
if grep -q "State Model" chapters/11-*.md; then
    echo "✅ Chapter 11 contains 'State Model'."
else
    echo "⚠️ Chapter 11 does not contain 'State Model'."
fi

if [ -f "artifacts/state_model_A.yaml" ] && [ -f "artifacts/state_model_B.yaml" ]; then
    echo "✅ State Models for A and B exist."
else
    echo "⚠️ State Models for A and B are missing."
fi

# 03-02-05: Ch 12 Artifacts & Verification Rubrics
if grep -q "Verification Rubric" chapters/12-*.md; then
    echo "✅ Chapter 12 contains 'Verification Rubric'."
else
    echo "⚠️ Chapter 12 does not contain 'Verification Rubric'."
fi

if [ -f "artifacts/verification_rubric_A.md" ] && [ -f "artifacts/verification_rubric_B.md" ]; then
    echo "✅ Verification Rubrics for A and B exist."
else
    echo "⚠️ Verification Rubrics for A and B are missing."
fi

# Artifact Count Check for Phase 3 (New artifacts only)
# Total expected: 10
PHASE_3_ARTIFACTS=("tool_schemas_A.json" "tool_schemas_B.json" "retrieval_map_A.md" "retrieval_map_B.md" "planning_template_A.md" "planning_template_B.md" "state_model_A.yaml" "state_model_B.yaml" "verification_rubric_A.md" "verification_rubric_B.md")
COUNT=0
for art in "${PHASE_3_ARTIFACTS[@]}"; do
    if [ -f "artifacts/$art" ]; then
        COUNT=$((COUNT+1))
    fi
done

if [ "$COUNT" -eq 10 ]; then
    echo "✅ All 10 Phase 3 artifacts found in /artifacts/."
else
    echo "⚠️ Found $COUNT of 10 Phase 3 artifacts."
fi

echo "Phase 03 Validation Summary Complete."
