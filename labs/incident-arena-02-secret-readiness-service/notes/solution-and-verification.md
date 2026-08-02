# Solution and Verification

#Change

Updated the Deployment Secret reference from:
environment
to:
app-environment
Updated the readiness probe path from:
/healthz
to:
/
# Verification

The Deployment successfully rolled out with one available replica.
The arena-api Pod became Running and Ready.
The EndpointSlice contained the ready arena-api Pod address on port 8080.
The client request returned:

application=arena-api
environment=production
status=running
The request completed successfully with exit code 0.

