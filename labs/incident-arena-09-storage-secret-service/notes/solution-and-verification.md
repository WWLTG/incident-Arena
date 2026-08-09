Solution and Verification
Change 1

Changed the PVC StorageClass from arena-local to standard.

The PVC became Bound and the application Pod could be scheduled.

Change 2

Changed the Secret key reference from app_mode to app-mode.

The application container started successfully and APP_MODE=production.

Change 3

Changed the Service selector from app=arena-api to app=arena-web.

The Service received a valid EndpointSlice endpoint and the client could reach the application.

Final verification
PVC is Bound.
Deployment is 1/1 Ready.
APP_MODE is production.
Service has a valid endpoint.
Client request through the Service succeeds.

Incident Arena 09 passed end-to-end verification.
