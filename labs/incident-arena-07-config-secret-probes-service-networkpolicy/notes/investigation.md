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

Failure 2

Observed failure

The new arena-api Pod is Running but remains 0/1 Ready.

Evidence

Pod events show:

Readiness probe failed: HTTP probe failed with statuscode: 404

The initContainer created:

/usr/share/nginx/html/ready

But the readiness probe checks:

/readyz

 Root cause

The readiness probe uses the wrong HTTP path.
---

Failure 3
Observed failure

The Deployment and Pod are healthy, but requests through the Service fail.

Evidence

The Service forwards traffic to port 8080.

The nginx container is reachable locally on port 80.

Root cause

The Service targetPort does not match the port where nginx is listening.

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
