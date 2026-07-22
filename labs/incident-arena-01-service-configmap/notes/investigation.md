# Investigation

# Service issue

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

# ConfigMap issue

# Observed failure

The application was reachable through the Service, but the response contained:

environment=development

The expected value was:

environment=production

# Evidence

The ConfigMap contained:

environment=development

The ConfigMap was mounted into the Nginx document root.

The mounted index.html file contained the same value.

# Root cause

The ConfigMap contained the wrong environment value.

