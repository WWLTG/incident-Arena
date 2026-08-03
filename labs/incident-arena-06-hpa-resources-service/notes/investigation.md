# Incident Arena 06 Investigation

Incident 1

Observed failure:
The client could not connect to arena-web-service, and its EndpointSlice contained no endpoints.

Evidence:
The application Pod had the label app=arena-web, while the Service selector was app=arena-api.

Root cause:
The Service selector did not match the Deployment Pod label, so Kubernetes could not register the Pod as a Service endpoint.

------------------------------------------------
Incident 2

Observed failure:
The HPA could not read the current scale, and its CPU target remained unknown.

Evidence:
The HPA referenced Deployment arena-api, while the only application Deployment was arena-web. The HPA reported FailedGetScale because arena-api was not found.

Root cause:
The HPA scaleTargetRef name did not match the existing Deployment name.



-----------------------------------------------

Incident 3

Observed failure:
The HPA found the Deployment but could not calculate CPU utilization, so the CPU target remained unknown.

Evidence:
The HPA reported FailedGetResourceMetric and stated that the arena-web container had no CPU request.

Root cause:
The Deployment container did not define a CPU request, which the utilization-based HPA requires to calculate CPU usage as a percentage.



-----------------------------------------------


Incident 4

Observed failure:
The application CPU utilization exceeded the HPA target, but the Deployment remained at one replica.

Evidence:
The HPA reported CPU utilization above the 50% target, ScalingLimited was True with the reason TooManyReplicas, and maxReplicas was set to 1.

Root cause:
The HPA maximum replica count prevented any scale-up because it was equal to the minimum replica count.



