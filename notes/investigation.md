# Investigation

# Observed failure
The arena-api Pod remains in CreateContainerConfigError.
The Deployment has zero available replicas, and the client request fails.

# Evidence
Pod events report:
Error: couldn't find key environment in Secret incident-arena-02/arena-api-settings

The Secret contains the key:
app-environment
The Deployment references the key:
environment

# Root cause
The Secret key referenced by the Deployment does not match the key stored in the Secret.
The Deployment requests environment, but the Secret defines app-environment.

----------------------
#problem 2

The arena-api Deployment initially had zero available replicas.
The first Pod remained in CreateContainerConfigError.

After correcting the Secret reference, the new Pod started but remained Running and not Ready.

The Deployment rollout could not complete, and the client request failed.

# Evidence
The first Pod events reported:
Error: couldn't find key environment in Secret incident-arena-02/arena-api-settings

The Secret contained:
app-environment
The Deployment referenced:

environment
After correcting the Secret reference, the container started successfully.
The new Pod events reported:
Readiness probe failed: HTTP probe failed with statuscode: 404
The readiness probe requested:
/healthz
The application served its content successfully from:
/

# Root cause

The incident had two configuration errors.
The Deployment referenced a Secret key that did not exist.
The readiness probe checked the nonexistent /healthz path instead of the application path /.

