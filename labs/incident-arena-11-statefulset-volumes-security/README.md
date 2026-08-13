# Incident Arena 11 — StatefulSet, Volumes, and SecurityContext

A Kubernetes troubleshooting lab with four sequential failures.

## Scenario

A stateful application should run as two ordered replicas in the
`incident-arena-11` namespace, each backed by its own persistent volume, and
each reachable individually through a headless Service using its stable
per-pod DNS name:

```text
arena-db-0.arena-db-headless.incident-arena-11.svc.cluster.local
arena-db-1.arena-db-headless.incident-arena-11.svc.cluster.local
```

The lab starts in a broken state. Investigate one failure at a time. Each fix
should reveal the next problem.

## Workflow

1. Apply the lab.

```bash
./scripts/apply-lab.sh
```

2. Run the baseline checks.

```bash
./scripts/baseline-tests.sh
```

3. Investigate the first visible failure with `kubectl`.

4. Record the evidence and root cause in:

```text
notes/investigation.md
```

5. Commit the investigation.

6. Fix only the current root cause.

7. Commit the fix.

8. Repeat until all four failures are resolved.

9. Run the final verification.

```bash
./scripts/final-verification.sh
```

10. Record the final result in:

```text
notes/solution-and-verification.md
```

## Rules

- Four intentional errors.
- Fix one error at a time.
- Keep each investigation and each fix in a separate Git commit.
- Do not replace the manifests with new resources.
- Use the existing resource names and intended architecture.
- If your cluster's default StorageClass has a different name, treat that
  mismatch itself as part of the investigation, not something to work around.
- Final verification must pass end to end.

## Main resources

- Namespace: `incident-arena-11`
- Headless Service: `arena-db-headless`
- StatefulSet: `arena-db`
- PVC template: `data`
- Client Pod: `arena-client`
