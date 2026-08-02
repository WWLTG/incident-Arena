# Incident Arena 02

## Scenario

An internal API is unavailable from the client Pod.

The namespace already contains a Secret, Deployment, Service, and client Pod. Restore the application without replacing the architecture or bypassing the health checks.

## Scope

- Secret
- Readiness probe
- Service and EndpointSlice

## Success criteria

- Deployment is `1/1` Ready.
- The Service has one ready endpoint.
- The client request succeeds and returns:

  application=arena-api
  environment=production
  status=running

## Rules

- Keep the application setting sourced from the Secret.
- Keep the readiness probe enabled.
- Fix one root cause at a time.
- Record concise evidence before changing the manifests.

## Workflow

1. Commit the broken lab.
2. Apply the manifests.
3. Run the baseline tests.
4. Investigate and document the root causes.
5. Commit the investigation.
6. Fix each root cause separately and verify after each change.
7. Write the final solution and verification notes.
8. Commit the completed incident.
