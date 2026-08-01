Solution and Verification
Change
Changed the Service selector from app=arena-service to app=arena-api.

Changed the NetworkPolicy namespace selector from arena-access=approved to arena-access=trusted.

Changed the Ingress backend Service port from web to http.

Verification
The Service EndpointSlice contained the application Pod endpoint on port 80.
The direct client request through the Service succeeded.
The request through Traefik succeeded.

Both baseline request exit codes returned 0.
