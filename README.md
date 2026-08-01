# Incident Arena 03

## Scenario

The application Pod is running, but users cannot reach it reliably.

This incident mixes several Kubernetes concepts:

- Deployment and Pod labels
- Service and EndpointSlice
- NetworkPolicy namespace selection
- Ingress backend routing

The lab starts in a broken state and contains three independent configuration problems.

## Prerequisites

- A running Kubernetes cluster
- kubectl configured for the cluster
- Traefik installed in namespace `traefik`
- IngressClass named `traefik`

## Workflow

1. Initialize and manage the Git repository yourself.
2. Preserve the original broken state in the first commit.
3. Apply the lab.
4. Run the baseline tests.
5. Investigate one failure at a time.
6. Document each root cause briefly.
7. Commit every meaningful fix separately.
8. Run the final verification.
9. Complete the solution documentation.

## Commands

Apply the lab:

    ./scripts/apply-lab.sh

Run baseline tests:

    ./scripts/baseline-tests.sh

Remove only the lab resources:

    ./scripts/cleanup-lab.sh

## Suggested first commit

    git add .
    git commit -m "Add broken Incident Arena 03"

## Expected final behavior

- The Deployment remains available.
- The Service has a ready EndpointSlice endpoint.
- The client Pod can reach the Service.
- The Ingress route for host `arena03.local` returns the application response.
