# Terraform - Azure Kubernetes Service Deployment

Setting up a full-fledged AKS cluster that can read images from Azure Container Registry (ACR), fetch secrets from Azure Key Vault using Pod Identity while all traffic is routed via an AKS managed Application Gateway is much harder.

This repository serves as a boilerplate for the scenario described above, and fully deploys and configures your Azure Kubernetes Service in the cloud using a single terraform deployment.

## Architecture

![Architecture Diagram AKS deployment](images/archdiagram_k8s.png?raw=true "Architecture Diagram AKS deployment")

The architecture consists of the following components:

__Public IP__ —
 Public IP addresses enable Azure resources to communicate to Internet and public-facing Azure services.

__Application Gateway__ —
Azure Application Gateway is a web traffic load balancer that enables you to manage traffic to your web applications.

__Azure Kubernetes Service (AKS)__ —
AKS is an Azure service that deploys a managed Kubernetes cluster.

__Virtual Network__ —
An Azure Virtual Network (VNet) is used to securely communicate between AKS and Application Gateway and control all outbound connections.

__Virtual Network subnets__ —
Application Gateway and AKS are deployed in their own subnets within the same virtual network.

__External Data Sources__ —
Microservices are typically stateless and write state to external data stores, such as CosmosDB.

__Azure Key Vault__ —
Azure Key Vault is a cloud service for securely storing and accessing secrets and certificates.

__Pod Identity__ —
Pod Identity enables Kubernetes applications to access cloud resources securely with Azure Active Directory.

__Azure Active Directory__ —
Azure Active Directory (Azure AD) is Microsoft's cloud-based identity and access management service. Pod Identity uses Azure AD to create and manage other Azure resources such as Azure Application Gateway and Azure Key Vault.

__Azure Container Registry__ —
Container Registry is used to store private Docker images, which are deployed to the cluster. AKS can authenticate with Container Registry using its Azure AD identity.

__KEDA__ —
KEDA is a Kubernetes-based Event Driven Autoscaler that (horizontally) scales a container by adding additional pods based on the number of events needing to be processed.

## Input Variables

| Name | Description | Default         |
|------|-------------|-----------------|
| `app_name` | Application name (used as suffix in all resources) |                 | 
| `location` | Azure region where to create resources | South asia    | 
| `domain_name_label` | Unique domain name label for AKS Cluster |                 | 
| `kubernetes_version` | Kubernetes version of the node pool | 1.28.9          | 
| `vm_size_node_pool` | VM Size of the node pool | Standard_D2s_v3 | 
| `node_pool_min_count` | VM minimum amount of nodes for the node pool | 1               | 
| `node_pool_max_count` | VM maximum amount of nodes for the node pool | 3               | 
| `helm_pod_identity_version` | Helm chart version of aad-pod-identity | 4.1.18          | 
| `helm_csi_secrets_version` | Helm chart version of secrets-store-csi-driver-provider-azure | 1.4.3           | 
| `helm_agic_version` | Helm chart version of ingress-azure-helm-package | 3.14.0          | 
| `helm_keda_version` | Helm chart version of keda helm package | 2.14.0          | 

## Output variables

| Name | Description |
|------|-------------|
| `aks_name` | Name of the AKS cluster |
| `appgw_name` | Name of the Application Gateway used by AKS |
| `appgw_fqdn` | Domain name of the cluster (e.g. `label.sgit outhasia.cloudapp.azure.com`) |
| `acr_name` | Name of the Azure Container Registry |
| `keyvault_name` | Name of the Azure Key Vault |
| `log_analytics_name` | Name of the Log Analytics workspace |
| `vnet_name` | Name of the Virtual Network |
| `rg_name` | Name of the Resource Group |



## Basic Commands
1. terraform init
Initializes a working directory containing Terraform configuration files. This command sets up the necessary backend and modules.

```bash
terraform init
```
2. terraform plan
Creates an execution plan, showing what actions Terraform will take to achieve the desired state defined in the configuration files.

```bash
terraform plan
```
3. terraform apply
Applies the changes required to reach the desired state of the configuration. This command prompts for approval before making any changes.
```bash
terraform apply
```
4. terraform destroy
Destroys the Terraform-managed infrastructure, reverting it to its previous state.

```
terraform destroy
```

NOTE: Using the .tfvars File with terraform plan
To create a plan using the .tfvars file, use the -var-file option with the terraform plan command:

```bash
terraform plan -var-file="variables.tfvars"
```


## Trouble Shooting
### Error Encryption at Host:
This Azure feature needs to be enabled at the subscription level. It encrypts your virtual machine's data while it is "at rest" on the host, protecting it from malicious activities, such as unauthorized access.
How to Resolve the Error
To resolve this issue, you need to enable the "Encryption at Host" feature for your Azure subscription. Here’s how you can do this:

1. Enable the Feature via Azure Portal:

- Log into the Azure Portal.
- Navigate to Subscriptions, select your subscription.
- Under Settings, go to Resource providers.
- Find and click on Microsoft.Compute.
- Check if the status of the "EncryptionAtHost" feature is registered. If not, you may need to register it.

2. Enable the Feature via Azure CLI:

- If you prefer using the command line, you can enable this feature using Azure CLI:
``` bash
az feature register --namespace Microsoft.Compute --name EncryptionAtHost
```
After registering, you may need to refresh the registration of the Microsoft.Compute provider:
```bash
az provider register -n Microsoft.Compute
```

### Register the Resource Provide
When creating AKS, if you got the error `No registered resource provider found for location 'southeastasia' and API version`, run the following command to register the Microsoft.ContainerService resource provider in your subscription:

``` bash
az provider register --namespace Microsoft.ContainerService
```
