# Incident Arena 10 — Investigation

 Failure 1

Observed failure

The arena-web Deployment cannot create its Pod.

Evidence

ReplicaSet events show that ResourceQuota requires CPU and memory requests and limits for the web container.

Root cause

The web container does not define resources.requests or resources.limits.



Failure 2

Observed failure
The arena-web Pod is stuck in CreateContainerConfigError.

Evidence

Pod events show that Kubernetes cannot find the app_environment key in the arena-web-config ConfigMap.
Root cause

The Deployment references a ConfigMap key that does not exist.


Failure 3

Observed failure
The new arena-web Pod is Running but remains 0/1 Ready.

Evidence
The readiness probe checks /readyz on port 80, but nginx serves the application from /.
A request to / succeeds while /readyz returns 404.

Root cause
The readiness probe uses an incorrect HTTP path.



Failure 4

Observed failure

Direct requests through arena-web-service succeed, but requests through Traefik return HTTP 404.

Evidence

The Ingress backend references arena-web-service on port 8080, while the Service exposes port 80.

Root cause

The Ingress references the wrong Service port.
