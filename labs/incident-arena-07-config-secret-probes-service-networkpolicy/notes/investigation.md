# Investigation

Failure 1
Observed failure

The arena-api Pod is stuck in Init:CreateContainerConfigError.

Evidence

The initContainer expects Secret key apiToken, but arena-api-secret contains api-token.

Pod events report:

couldn't find key apiToken in Secret incident-arena-07-app/arena-api-secret

Root cause

The Deployment references the wrong Secret key name.
---

## Failure 2

### Observed failure

### Evidence

### Root cause

---

## Failure 3

### Observed failure

### Evidence

### Root cause

---

## Failure 4

### Observed failure

### Evidence

### Root cause

---

## Failure 5

### Observed failure

### Evidence

### Root cause
