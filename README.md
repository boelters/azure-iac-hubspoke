# Azure IaC - Hub and Spoke Environment

This repo contains modular Bicep templates to deploy a secure Azure environment using a hub-and-spoke network topology, with support for:
- Azure Firewall
- Active Directory domain controllers
- IIS web app VM
- Azure App Service

## Modules
- `/modules/core`: Networking and firewall
- `/modules/identity`: Domain controllers + DNS
- `/modules/compute`: VM with IIS
- `/modules/appservice`: Azure App Service

## Environments
- `/environments/dev`: Parameter files and orchestration for a dev environment

## Deployment
See `/scripts` or `.github/workflows` for deployment steps.

## Prereqs
- main.bicep is hard coded to refer to iac-hub as our rg -- modify as needed and ensure the rg exists prior to deployment
- a keyvault is required with the following secrets:
- iac-admin-password [admin pwd for vms]
