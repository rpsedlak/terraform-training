# Tasks: Environment Naming

**Related spec:** [spec.md](spec.md)  
**Related plan:** [plan.md](plan.md)  
**Status:** Not started

## Specification

- [x] Approve the CAF component pattern and Azure naming exceptions (ADR-014).
- [x] Select the `environment` input and its allowed values.

## Implementation

- [ ] Add a central environment input and mapping for `d`, `t`, and `p`.
- [ ] Apply the derived code consistently to named resources where Azure rules permit.
- [ ] Preserve service-mandated names and document exceptions.

## Verification

- [ ] Verify development, testing, and production map to `d`, `t`, and `p`.
- [ ] Verify unsupported environment values are rejected.
- [ ] Verify planned names comply with Azure naming rules and preserve required names.
- [ ] Record check results and evidence.

## Completion notes

<Summarize what changed, checks run, and any remaining limitations.>