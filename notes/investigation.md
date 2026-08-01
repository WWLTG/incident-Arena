# Incident Arena 03 Investigation

 Issue 1

# Observed failure
The client could not connect to arena-api-service.

# Evidence
The arena-api Pod had the label app=arena-api.
The Service selector was app=arena-service.
The EndpointSlice contained no endpoints or ports.

# Root cause
The Service selector did not match the application Pod label.


Issue 2
Observed failure
The Service had a valid endpoint, but the direct client request timed out.

Evidence
The application responded successfully from inside the arena-api Pod.
The client namespace had the label arena-access=trusted.
The NetworkPolicy allowed client namespaces with arena-access=approved.

Root cause
The NetworkPolicy namespace selector did not match the client namespace label.

Issue 3
Observed failure
The direct Service request succeeded, but the request through Traefik returned HTTP 404.

Evidence
The Ingress backend referenced the Service port named web.
The arena-api-service port was named http.

Root cause
The Ingress backend port name did not match the Service port name.
