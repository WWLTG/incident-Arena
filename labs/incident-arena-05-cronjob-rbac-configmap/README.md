# Incident Arena 05

## Scenario

A scheduled reporting workload must read one ConfigMap through the Kubernetes API and print the configured report message.

The CronJob exists, but its manually triggered Job does not complete successfully.

## Level

Medium

## Intentional errors

4 sequential errors

Each fix should reveal the next problem.

## Concepts

- CronJob and Job
- ServiceAccount
- Role and RoleBinding
- ConfigMap

## Rules

- Investigate before editing manifests
- Keep each investigation in a separate Git commit
- Keep each fix in a separate Git commit
- Do not fix multiple errors in one commit
- Keep notes concise

## Start

Run all commands from inside the toolbox.

    cd incident-arena-05-cronjob-rbac-configmap
    ./scripts/apply-lab.sh
    ./scripts/baseline-tests.sh

The CronJob is suspended intentionally so the lab does not create Jobs repeatedly. The scripts trigger a manual Job from the CronJob template.

## Investigation files

Use:

- notes/investigation.md
- notes/solution-and-verification.md

## Final verification

After all fixes:

    ./scripts/final-verification.sh
