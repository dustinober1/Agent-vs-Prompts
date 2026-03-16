#!/bin/bash

# Phase 01 - Validation Suite

set -e

echo "Running Phase 01 Validation Suite..."

# 01-01-01: Initialize /artifacts/
if [ -d "artifacts/" ]; then
    echo "✅ artifacts/ directory exists."
else
    echo "❌ artifacts/ directory is missing."
    exit 1
fi

# 01-01-02: Ch 1 Artifacts
if grep -q "Plateau Symptom Checklist" chapters/01-*.md; then
    echo "✅ Chapter 1 contains 'Plateau Symptom Checklist'."
else
    echo "⚠️ Chapter 1 does not contain 'Plateau Symptom Checklist'."
fi

# 01-01-03: Ch 2 Artifacts
if grep -q "Failure Budget" chapters/02-*.md; then
    echo "✅ Chapter 2 contains 'Failure Budget'."
else
    echo "⚠️ Chapter 2 does not contain 'Failure Budget'."
fi

# 01-01-04: Ch 3 Artifacts
if grep -q "Prompt-Component Map" chapters/03-*.md; then
    echo "✅ Chapter 3 contains 'Prompt-Component Map'."
else
    echo "⚠️ Chapter 3 does not contain 'Prompt-Component Map'."
fi

# 01-01-05: Ch 4 Artifacts
if grep -q "Prompt Surface Area Budget" chapters/04-*.md; then
    echo "✅ Chapter 4 contains 'Prompt Surface Area Budget'."
else
    echo "⚠️ Chapter 4 does not contain 'Prompt Surface Area Budget'."
fi

# 01-01-06: Standalone Artifacts
ARTIFACT_COUNT=$(ls artifacts/*.md 2>/dev/null | wc -l | xargs)
if [ "$ARTIFACT_COUNT" -eq 10 ]; then
    echo "✅ Found $ARTIFACT_COUNT artifacts in /artifacts/."
else
    echo "⚠️ Expected 10 markdown artifacts in /artifacts/, but found $ARTIFACT_COUNT."
    # List missing artifacts if needed, but for now just show count.
fi

echo "Phase 01 Validation Summary Complete."
