Incident Arena Study

Purpose

This project contains lightweight troubleshooting arenas that mix previously studied Kubernetes fundamentals.

Current arena

incident-arena-01-service-configmap

Rules

- Work inside the toolbox k8s environment.
- Apply only the manifests inside the current arena.
- Do not edit manifests before collecting baseline evidence.
- Follow the request path from Client Pod to Service to EndpointSlice to Destination Pod.
- Record the investigation before applying fixes.
- Fix one problem at a time and verify after every meaningful change.
- Keep the lab lightweight. Do not run stress or load tests.

Git workflow

The first commit preserves the untouched broken state.

Suggested later commits

- Document Incident Arena 01 investigation
- Fix Incident Arena 01 service routing
- Fix Incident Arena 01 application configuration
- Complete Incident Arena 01 verification
