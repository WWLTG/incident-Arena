Change

Corrected the StatefulSet PVC reference from arena-store-dtaa to arena-store-data.
Corrected the ConfigMap volume key from index.htlm to index.html.
Corrected the headless Service selector from app=arena-storage to app=arena-store.
Updated DNS verification to use fully qualified cluster domain names.

Verification

The PVC became Bound and remained attached after the StatefulSet Pod was recreated.
The StatefulSet reached 1/1 Ready, and the init container completed successfully.
The EndpointSlice contained the arena-store-0 Pod address on port 80.
The Service DNS and stable StatefulSet Pod DNS resolved successfully.
The client HTTP request returned the expected production content.
The created_at value remained unchanged after Pod recreation, confirming persistent storage.
