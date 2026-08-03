# Incident Arena 06

## Level

Medium

## Scope

This lab combines:

- Deployment
- Service and EndpointSlice
- Resource requests and limits
- HorizontalPodAutoscaler
- Metrics API
- Controlled load verification

The lab contains four intentional errors. They are designed to be investigated and fixed in sequence.

## Rules

- Do not run `git init` inside this directory.
- Keep this lab under the existing `incident-arena/labs` directory.
- Commit the broken lab before making any fix.
- Commit every investigation separately.
- Commit every fix separately.
- Keep `notes/investigation.md` concise.
- Keep `notes/solution-and-verification.md` concise.
- Use the final verification script only after all incidents are fixed.

## Expected workflow

From the root of the existing repository:

    git add labs/incident-arena-06-hpa-resources-service
    git commit -m "Add broken Incident Arena 06 lab"

Then enter the lab:

    cd labs/incident-arena-06-hpa-resources-service

Apply the broken scenario:

    ./scripts/apply-lab.sh

Run the baseline:

    ./scripts/baseline-tests.sh

For each incident:

1. Investigate the current failure.
2. Record direct evidence and the root cause.
3. Commit the investigation.
4. Apply one focused fix.
5. Verify that fix.
6. Commit the fix.
7. Continue until the next failure becomes visible.

Suggested neutral commit pattern:

    git commit -m "Document Incident Arena 06 incident 1 investigation"
    git commit -m "Fix Incident Arena 06 incident 1"

After all four fixes:

    ./scripts/final-verification.sh

Then finish the concise solution document and commit it:

    git commit -m "Document Incident Arena 06 solution and verification"

## Useful commands

    kubectl get all -n incident-arena-06
    kubectl get endpointslice -n incident-arena-06
    kubectl get hpa -n incident-arena-06
    kubectl describe hpa arena-web-hpa -n incident-arena-06
    kubectl top pods -n incident-arena-06
    kubectl get events -n incident-arena-06 --sort-by=.metadata.creationTimestamp

Use the controlled load script when the service path is available:

    ./scripts/generate-load.sh
