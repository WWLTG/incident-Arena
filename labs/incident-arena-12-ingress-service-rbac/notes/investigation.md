# Investigation Log — Lab 12: ingress-service-rbac

# Failure 1

Curl through the Ingress failed, connection refused. Checked kubectl get ingress, backend service port was set to 8080. Checked kubectl get svc feature-flag-svc, the Service only exposes port 80. Ingress was pointing at a port the Service does not have. Changed the Ingress backend port to 80 to match the Service.

## Failure 2


## Failure 3

