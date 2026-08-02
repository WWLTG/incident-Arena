# Incident Arena 04

# Scenario

A stateful internal web service should store its generated content on persistent storage and be reachable through a headless Service.

The lab is intentionally broken. More than one failure exists, and later failures may stay hidden until earlier ones are fixed.

# Concepts mixed in this incident

- StatefulSet
- PersistentVolumeClaim and StorageClass
- ConfigMap volume
- Headless Service and EndpointSlice
- Stable Pod DNS
- Persistent data after Pod recreation

# Target healthy state

- The PVC becomes Bound
- The StatefulSet becomes Ready 1/1
- The Pod mounts the ConfigMap and persistent storage
- The headless Service has a ready endpoint
- The client reaches the application
- The stable Pod DNS name resolves
- The persistent creation marker survives Pod recreation

# Environment

Run all commands inside the Kubernetes toolbox.

Confirm the active context before applying the lab:

    kubectl config current-context

The lab expects a local cluster with a working local-path provisioner such as the one used by the standard StorageClass in the current kind environment.

# Start the incident

    chmod +x scripts/*.sh
    ./scripts/apply-lab.sh
    ./scripts/baseline-tests.sh

Do not run final verification until all failures are fixed.

# Investigation workflow

Use the normal path and stop at direct evidence before editing YAML:

    kubectl get statefulset,pod,pvc,service,endpointslice -n incident-arena-04
    kubectl describe pod arena-store-0 -n incident-arena-04
    kubectl describe pvc arena-store-data -n incident-arena-04
    kubectl get events -n incident-arena-04 --sort-by=.metadata.creationTimestamp
    kubectl logs arena-store-0 -n incident-arena-04 -c prepare-content
    kubectl exec arena-client -n incident-arena-04 -- nslookup arena-store
    kubectl exec arena-client -n incident-arena-04 -- wget -qO- -T 3 http://arena-store

# Git stages

Repository initialization is intentionally not included in this package.

Keep every investigation and every meaningful fix in a separate commit. A suitable sequence is:

1. Add broken Incident Arena 04 lab
2. Document the first investigation
3. Apply the first fix
4. Document the second investigation
5. Apply the second fix
6. Document the third investigation
7. Apply the third fix
8. Document final solution and verification

For the first investigation, rename the template and add only concise evidence:

    git mv notes/investigation-template.txt notes/investigation.md

For the final documentation:

    git mv notes/solution-and-verification-template.txt notes/solution-and-verification.md

# Documentation standard

investigation.md

- Observed failure
- Evidence
- Root cause

solution-and-verification.md

- Change
- Verification

Keep each section short and practical.

# Final verification

    ./scripts/final-verification.sh

The final script verifies workload health, service discovery, HTTP output, stable Pod DNS, and persistent data across Pod recreation.

# Reset

    ./scripts/reset-lab.sh
