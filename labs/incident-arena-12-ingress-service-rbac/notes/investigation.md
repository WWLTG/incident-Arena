# Investigation Log — Lab 12: ingress-service-rbac

# Failure 1

Curl through the Ingress failed, connection refused. Checked kubectl get ingress, backend service port was set to 8080. Checked kubectl get svc feature-flag-svc, the Service only exposes port 80. Ingress was pointing at a port the Service does not have. Changed the Ingress backend port to 80 to match the Service.

# Failure 2

Pod initContainer stuck in Init:CrashLoopBackOff with Forbidden errors, even after the Ingress port fix. Checked kubectl describe rolebinding, subject was named flag-reader-sa but the pod actually uses ServiceAccount flag-reader, a mismatch. Confirmed with kubectl auth can-i --as=system:serviceaccount, which returned no. Fixed the RoleBinding subject name to flag-reader and reapplied. Deleted the stuck pod to skip the CrashLoopBackOff backoff timer, new pods came up Running 1/1.

# Failure 3

After both previous fixes, curl through the Ingress still returned 503, Service had no endpoints. Checked kubectl get svc feature-flag-svc, selector was app: feature-flag-api. Checked kubectl get pods --show-labels, pods are actually labeled app: flag-api. Selector never matched the pods, so the EndpointSlice stayed empty regardless of pod health. Fixed the Service selector to app: flag-api and reapplied.
