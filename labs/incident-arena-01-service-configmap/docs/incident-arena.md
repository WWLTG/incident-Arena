Incident Arena

An Incident Arena is a troubleshooting exercise that combines multiple Kubernetes concepts in one small scenario.

The goal is not to guess the broken field immediately.

The goal is to collect evidence and trace the full path step by step.

Investigation path

Client Pod
Service
EndpointSlice
Destination Pod
Application configuration

Expected workflow

1. Apply the broken lab.
2. Run the baseline tests.
3. Inspect resources without editing them.
4. Record the observed failure and evidence.
5. Identify the root causes.
6. Fix one problem at a time.
7. Verify the complete request path.
8. Document the final solution and verification.
