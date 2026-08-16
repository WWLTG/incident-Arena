# Incident Arena 12 — ingress-service-rbac

## Scenario
`feature-flag-api` is a small app: an initContainer (using a `flag-reader`
ServiceAccount) pulls a `feature-flags` ConfigMap into a shared volume, and
an nginx container serves that file. The app is exposed by a Service and
reached externally through an Ingress. Traffic enters at the Ingress and has
to survive three layers before it reaches a healthy pod.

Namespace: `incident-arena-12`

## Intentional bugs (fix in this order — matches the Ingress → Service →
EndpointSlice → Pod → Container investigation path)

1. **Ingress → Service port mismatch**: the Ingress backend points at port
   `8080`, but the Service only exposes port `80`. Symptom: requests through
   the Ingress fail (502/connection refused) even though the Service itself
   is fine.
2. **Service selector mismatch**: the Service selects `app: feature-flag-api`,
   but the pods are labeled `app: flag-api`. Symptom: after fixing bug 1,
   the Ingress reaches the Service but gets a 503 — EndpointSlice is empty.
3. **RBAC identity mismatch**: the RoleBinding's subject is
   `flag-reader-sa`, but the pod's actual ServiceAccount is `flag-reader`.
   Symptom: after fixing bug 2, traffic reaches real pods, but they're stuck
   in `Init:CrashLoopBackOff` — the initContainer gets Forbidden trying to
   read the ConfigMap.

## Usage
```bash
scripts/apply-lab.sh          # deploy the broken lab
scripts/baseline-tests.sh     # non-blocking diagnostics, confirms the breakage
# ... investigate and fix, one commit per step ...
scripts/final-verification.sh # strict pass/fail check once all three are fixed
```

## Structure
```
manifests/   numbered manifests, apply in order
notes/       investigation.md + solution-and-verification.md
scripts/     apply-lab.sh, baseline-tests.sh, final-verification.sh
```

## Prerequisites
- `kind` cluster with an nginx Ingress Controller + `IngressClass` installed
  (same as the Ingress topic lab)
- `kubectl`
