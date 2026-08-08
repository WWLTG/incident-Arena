Changes
Corrected the Secret key reference from apiToken to api-token.
Corrected the readiness probe path from /readyz to /ready.
Corrected the Service target port to the nginx HTTP port.
Corrected the NetworkPolicy namespace selector to match the client namespace label.
Verification

The Deployment reached 1/1 Ready.

The Service EndpointSlice points to the application Pod on port 80.

The client in incident-arena-07-client successfully reached the Service.

The final response contained:

message=incident-arena-07

api_token=arena07-token

status=running

Final end-to-end verification passed.
