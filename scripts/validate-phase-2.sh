#!/bin/bash

# Phase 02 - Validation Suite

set -e

echo "Running Phase 02 Validation Suite..."

# 02-02-01: Ch 5 Artifacts & Agent Specs
if grep -q "Agent Spec" chapters/05-*.md; then
    echo "✅ Chapter 5 contains 'Agent Spec'."
else
    echo "⚠️ Chapter 5 does not contain 'Agent Spec'."
fi

if [ -f "artifacts/agent_spec_A_research_write.yaml" ] && [ -f "artifacts/agent_spec_B_instructional_design.yaml" ]; then
    echo "✅ Agent Specs for A and B exist."
else
    echo "⚠️ Agent Specs for A and B are missing."
fi

# 02-02-02: Ch 6 Artifacts & MVA Decision Records
if grep -q "MVA Decision Record" chapters/06-*.md; then
    echo "✅ Chapter 6 contains 'MVA Decision Record'."
else
    echo "⚠️ Chapter 6 does not contain 'MVA Decision Record'."
fi

if [ -f "artifacts/mva_A_research_write.md" ] && [ -f "artifacts/mva_B_instructional_design.md" ]; then
    echo "✅ MVA Decision Records for A and B exist."
else
    echo "⚠️ MVA Decision Records for A and B are missing."
fi

# 02-02-03: Ch 7 Artifacts & Agent Loops
if grep -q "Agent Loop" chapters/07-*.md; then
    echo "✅ Chapter 7 contains 'Agent Loop'."
else
    echo "⚠️ Chapter 7 does not contain 'Agent Loop'."
fi

if [ -f "artifacts/agent_loop_A.md" ] && [ -f "artifacts/agent_loop_B.md" ]; then
    echo "✅ Agent Loop diagrams/configs for A and B exist."
else
    echo "⚠️ Agent Loop diagrams/configs for A and B are missing."
fi

# Artifact Count Check for Phase 2 (New artifacts only)
# Total expected: 6 (Specs, MVAs, Loops)
PHASE_2_ARTIFACTS=("agent_spec_A_research_write.yaml" "agent_spec_B_instructional_design.yaml" "mva_A_research_write.md" "mva_B_instructional_design.md" "agent_loop_A.md" "agent_loop_B.md")
COUNT=0
for art in "${PHASE_2_ARTIFACTS[@]}"; do
    if [ -f "artifacts/$art" ]; then
        COUNT=$((COUNT+1))
    fi
done

if [ "$COUNT" -eq 6 ]; then
    echo "✅ All 6 Phase 2 artifacts found in /artifacts/."
else
    echo "⚠️ Found $COUNT of 6 Phase 2 artifacts."
fi

echo "Phase 02 Validation Summary Complete."
