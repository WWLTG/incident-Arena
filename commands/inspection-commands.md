Incident Arena 01 inspection commands

Set the namespace

kubectl config set-context --current --namespace=incident-arena-01

List resources

kubectl get all
kubectl get configmap
kubectl get endpointslice

Check workload state

kubectl get deployment arena-web
kubectl rollout status deployment/arena-web
kubectl get pods -o wide
kubectl describe deployment arena-web
kubectl describe pod -l app=arena-web

Inspect Service routing

kubectl get service arena-web-service -o wide
kubectl describe service arena-web-service
kubectl get endpointslice -l kubernetes.io/service-name=arena-web-service -o wide

Inspect labels and selectors

kubectl get pods --show-labels
kubectl get service arena-web-service -o yaml
kubectl get deployment arena-web -o yaml

Inspect application configuration

kubectl get configmap arena-web-config -o yaml
kubectl exec deployment/arena-web -- cat /usr/share/nginx/html/index.html

Test from the Client Pod

kubectl exec arena-client -- wget -qO- --timeout=3 http://arena-web-service

echo $?

Check recent events

kubectl get events --sort-by=.metadata.creationTimestamp
