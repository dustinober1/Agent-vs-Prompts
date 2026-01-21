# Chapter 2 — Failure modes you can’t prompt away

## Purpose
Make the limits of prompting concrete with a taxonomy of failures.

## Reader takeaway
The most important failures are systemic (missing data, hidden constraints, long-horizon drift, adversarial inputs) and require external controls.

## Key points
- Hallucination vs fabrication vs speculation
- Context limits and information overload
- Hidden assumptions and “unknown unknowns”
- Long-horizon compounding error
- Non-determinism and variance
- The “format trap” (JSON/citations/structure drift)
- Adversarial inputs: prompt injection, jailbreaks, social engineering

## Case study thread
### Research+Write (Policy change brief)
- Fabricated or low-quality citations
- Citation laundering (“sounds cited but isn’t”)
- Confidentiality risk: leaking internal details when mixing internal+web sources

### Instructional Design (Annual compliance training)
- Misalignment: objectives ≠ assessments ≠ activities
- Policy drift: training contradicts the current policy wiki/SOPs
- Accessibility issues that aren’t fixed by “please be accessible”

## Artifacts to produce
- A failure-mode matrix for each agent (impact × likelihood × detectability)

## Chapter exercise
Write a “failure budget” for both case studies (what can go wrong and how you’ll detect it).

## Notes / references
- TODO: define the minimum “detectability” signals you will instrument later

