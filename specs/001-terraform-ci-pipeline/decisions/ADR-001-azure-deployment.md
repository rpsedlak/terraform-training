# ADR-001: Deploy the System to Microsoft Azure

**Status:** Accepted  
**Date:** 2026-10-14

## Context

The Terraform CI pipeline training example needs a defined deployment target so its infrastructure and deployment workflow can be designed consistently.

## Decision

The system will be deployed to Microsoft Azure. Terraform configuration and deployment workflows for this feature will target Azure.

## Consequences

- Terraform provider configuration and resources will be Azure-specific.
- The Azure services, root module scope, CI platform, Terraform version, state backend, and execution identity remain separate decisions and must be recorded before implementation.
- Azure credentials and state must be handled through approved secure mechanisms and must not be committed to the repository.