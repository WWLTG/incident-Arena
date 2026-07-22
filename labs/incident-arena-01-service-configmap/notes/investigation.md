# Investigation

# Observed failure
The client could not connect to arena-web-service.
The Service EndpointSlice contained no endpoints.

# Evidence
The Service selector was:
app=web

The application Pod label was:
app=arena-web
A direct request to the Pod IP succeeded.

# Root cause

The Service selector did not match the Deployment Pod labels, so the Service could not select the application Pod.
