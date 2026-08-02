# Solution and Verification
 Change

Updated the Service selector from:
app=web
to:
app=arena-web

Updated the ConfigMap environment value from:

environment=development

to:

environment=production

## Verification
The Service EndpointSlice contained the application Pod endpoint.
The client successfully accessed arena-web-service.

The mounted ConfigMap file contained:

environment=production

The final application response was:
application=arena-web
environment=production
status=running

The request completed successfully with exit code 0.

