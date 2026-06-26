# Validation Report

## Scope

New `enterpriseapplication` module for Microsoft Entra Enterprise Application service principals, app registration connection, app role assignments, and optional Application Proxy configuration.

## Notes

- Application Proxy is configured through Microsoft Graph beta `onPremisesPublishing`.
- The module uses `azuread_service_principal` for the Enterprise Application lifecycle.
