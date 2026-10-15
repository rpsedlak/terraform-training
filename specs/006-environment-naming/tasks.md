# Tasks: Environment Naming

**Related spec:** [spec.md](spec.md)  
**Related plan:** [plan.md](plan.md)  
**Status:** In Progress

## Public Access Revision: ADR-018

- [x] Retain the distinct `pip-server-...` name under ADR-018 and remove the JIT policy name.
- [x] Remove active Bastion names and JIT combined-name constraints; mock tests retain environment naming coverage.
- [ ] Verify names in the authorized environment's live migration plan.

## Specification

- [x] Approve the CAF component pattern and Azure naming exceptions (ADR-014).
- [x] Select the `environment` input and its allowed values.

## Implementation

- [x] Add a central environment input and mapping for `d`, `t`, and `p`.
- [x] Apply the derived code consistently to named resources where Azure rules permit.
- [x] Preserve service-mandated names and document exceptions.

## Verification

- [x] Verify development, testing, and production map to `d`, `t`, and `p`.
- [x] Verify unsupported environment values are rejected.
- [ ] Verify planned names comply with Azure naming rules and preserve required names.
- [ ] Record check results and evidence.

## Completion notes

Offline tests verify the development/testing/production codes and resource-name examples. Azure resource-specific name constraints still require review in a real plan. No deployment was run.