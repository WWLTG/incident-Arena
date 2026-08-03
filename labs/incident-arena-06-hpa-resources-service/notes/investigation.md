# Incident Arena 06 Investigation

Incident 1

Observed failure:
The client could not connect to arena-web-service, and its EndpointSlice contained no endpoints.

Evidence:
The application Pod had the label app=arena-web, while the Service selector was app=arena-api.

Root cause:
The Service selector did not match the Deployment Pod label, so Kubernetes could not register the Pod as a Service endpoint.

------------------------------------------------




-----------------------------------------------





-----------------------------------------------






