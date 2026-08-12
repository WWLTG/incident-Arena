# Incident Arena 10 — ResourceQuota, ConfigMap, Readiness, and Ingress

A Kubernetes troubleshooting lab with four sequential failures.

## Scenario

An application should run in the `incident-arena-10` namespace and be reachable through Traefik using:

```text
Host: arena10.local
```

The lab starts in a broken state. Investigate one failure at a time. Each fix should reveal the next problem.

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
- Final verification must pass end to end.

## Main resources

- Namespace: `incident-arena-10`
- ResourceQuota: `arena-quota`
- ConfigMap: `arena-web-config`
- Deployment: `arena-web`
- Service: `arena-web-service`
- Ingress: `arena-web-ingress`
- Client Pod: `arena-client`
