# Investigation

Incident 1

Observed failure
The StatefulSet Pod remained Pending and could not be scheduled.

Evidence
The Pod event reported that PersistentVolumeClaim arena-store-dtaa was not found.
The existing PVC was named arena-store-data and remained in WaitForFirstConsumer state.

Root cause
The StatefulSet referenced the wrong PersistentVolumeClaim name because of a typo in claimName.

Incident 2

Observed failure
The StatefulSet Pod remained stuck during volume initialization.

Evidence
The Pod event reported:
MountVolume.SetUp failed for volume content because the ConfigMap referenced the non-existent key index.htlm.

Root cause
The StatefulSet ConfigMap volume contained a typo in the items key.
It referenced index.htlm instead of the existing ConfigMap key index.html.

Incident 3
Observed failure
The StatefulSet Pod was healthy, but the client could not resolve or access the headless Service.

Evidence
The Service selector was app=arena-storage.
The StatefulSet Pod label was app=arena-store.
The EndpointSlice contained no endpoints, and the client DNS and HTTP tests failed.

Root cause
The headless Service selector did not match the StatefulSet Pod label.
