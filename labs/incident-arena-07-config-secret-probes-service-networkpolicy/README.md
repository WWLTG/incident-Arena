# Incident Arena 07

## Scenario

An internal web application is deployed in `incident-arena-07-app`.
A client Pod in `incident-arena-07-client` must be able to reach it through the Service.

The lab contains five intentional, sequential troubleshooting errors.
Fix one problem at a time. Each investigation and each fix should be committed separately.

## Rules

- Do not recreate the lab from scratch after each failure.
- Investigate before editing manifests.
- Keep each investigation in its own Git commit.
- Keep each fix in its own Git commit.
- Do not change more than the issue currently being investigated.
- Final verification must validate the complete end-to-end path.

## Start

```bash
./scripts/apply-lab.sh
./scripts/baseline-tests.sh
```

## Main namespaces

- `incident-arena-07-app`
- `incident-arena-07-client`
