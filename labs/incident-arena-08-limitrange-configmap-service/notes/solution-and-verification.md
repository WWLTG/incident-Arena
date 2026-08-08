Incident Arena 08 — Solution and Verification
Change 1

Reduced the Deployment container memory limit from 512Mi to 256Mi so it complies with the namespace LimitRange.

Verification 1

The ReplicaSet successfully created the application Pod.

Change 2

Corrected the ConfigMap key reference in the Deployment from app-environment to environment.

Verification 2

The container started successfully and the application Pod reached the Running and Ready state.

Change 3

Corrected the Service selector from app=arena-api to app=arena-web.

Verification 3

The Service EndpointSlice populated with the application Pod endpoint on port 8080.

Final verification
./scripts/final-verification.sh

The Deployment successfully rolled out.

The application Pod and client Pod were Ready.

The Service had a valid endpoint.

The client successfully reached the application through arena-web-service.

Expected response:

application=arena-web
environment=production
status=running

Final result:

Incident Arena 08 verification passed
