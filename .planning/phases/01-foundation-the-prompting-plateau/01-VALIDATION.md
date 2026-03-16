---
phase: 01
slug: foundation-the-prompting-plateau
status: draft
nyquist_compliant: true
wave_0_complete: true
created: 2026-03-15
---

# Phase 01 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Shell (test -f, grep) |
| **Config file** | none — Wave 0 installs |
| **Quick run command** | `test -f artifacts/*.md` |
| **Full suite command** | `./scripts/validate-phase-1.sh` |
| **Estimated runtime** | ~5 seconds |

---

## Sampling Rate

- **After every task commit:** Run `test -f {artifact_path}`
- **After every plan wave:** Run `./scripts/validate-phase-1.sh`
- **Before /gsd:verify-work:** Full suite must be green
- **Max feedback latency:** 5 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 01-01-01 | 01 | 1 | Initialize /artifacts/ | unit | `ls -d artifacts/` | ✅ | ✅ green |
| 01-01-02 | 01 | 1 | Ch 1 Artifacts | integration | `grep "Plateau Symptom Checklist" chapters/01-*.md` | ✅ | ✅ green |
| 01-01-03 | 01 | 2 | Ch 2 Artifacts | integration | `grep "Failure Budget" chapters/02-*.md` | ✅ | ✅ green |
| 01-01-04 | 01 | 2 | Ch 3 Artifacts | integration | `grep "Prompt-Component Map" chapters/03-*.md` | ✅ | ✅ green |
| 01-01-05 | 01 | 3 | Ch 4 Artifacts | integration | `grep "Prompt Surface Area Budget" chapters/04-*.md` | ✅ | ✅ green |
| 01-01-06 | 01 | 3 | Standalone Artifacts | unit | `ls artifacts/*.md | wc -l | grep 10` | ✅ | ✅ green |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [x] `mkdir -p artifacts/` — initialize directory
- [x] `touch artifacts/.gitkeep` — ensure tracked
- [x] `./scripts/validate-phase-1.sh` — create validation script

*If none: "Existing infrastructure covers all phase requirements."*

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Reading Quality | Ch 1-4 | Creative content | Review chapters for tone, clarity, and argument flow. |
| Case Study Baseline | Naive Prompts | Intentional failure | Verify baseline prompts "fail well" as described in research. |

*If none: "All phase behaviors have automated verification."*

---

## Validation Sign-Off

- [x] All tasks have <automated> verify or Wave 0 dependencies
- [x] Sampling continuity: no 3 consecutive tasks without automated verify
- [x] Wave 0 covers all MISSING references
- [x] No watch-mode flags
- [x] Feedback latency < 5s
- [x] `nyquist_compliant: true` set in frontmatter

**Approval:** pending 2026-03-15
