# Tasks: Environment Naming

**Related spec:** [spec.md](spec.md)  
**Related plan:** [plan.md](plan.md)  
**Status:** Not started

## Specification

- [ ] Approve the complete resource naming pattern, including code position and separators.
- [ ] Document resource-specific Azure naming exceptions.
- [ ] Decide the environment-selection parameter used by local and CI workflows.

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