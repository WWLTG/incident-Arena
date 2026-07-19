Incident Arena 01

Scenario

A small internal web application was deployed behind a ClusterIP Service.

A client inside the same namespace must reach the application by Service name.

The application must return the expected environment value.

Expected final result

- The Deployment is Available.
- The Service has a ready endpoint.
- The client can reach http://arena-web-service.
- The response contains environment=production.

Constraints

- The arena contains two independent configuration problems.
- Do not add new workloads or Services.
- Do not expose the application outside the cluster.
- Do not change the container image.
- Fix one problem at a time.
- Keep investigation.md concise.
- Keep solution-and-verification.md concise.

Start

Run scripts/apply-lab.sh from the arena directory.

Then run scripts/baseline-tests.sh.
