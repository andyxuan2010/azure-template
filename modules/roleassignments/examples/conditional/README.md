# Conditional Role Assignment

Assigns Storage Blob Data Reader with an Azure RBAC condition that limits access to one container name.

Azure validates condition syntax at apply time. Test the condition against the intended storage data-plane operations before production rollout.
