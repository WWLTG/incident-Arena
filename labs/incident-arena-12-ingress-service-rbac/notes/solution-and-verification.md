# Solution & Verification — Lab 12: ingress-service-rbac

Fix 1
Ingress backend port changed from 8080 to 80 to match the Service port (manifests/05-ingress.yaml).

Fix 2
RoleBinding subject name changed from flag-reader-sa to flag-reader to match the pod's actual ServiceAccount (manifests/02-rbac.yaml).

Fix 3
Service selector changed from app: feature-flag-api to app: flag-api to match the pod labels (manifests/04-service.yaml).

Final Verification
Ran scripts/final-verification.sh: RoleBinding subject, Service selector, Ingress backend port, and pod readiness all confirmed correct via kubectl jsonpath checks. Curl through the Ingress returns the feature-flags content end to end.
