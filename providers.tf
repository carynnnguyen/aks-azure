terraform {
  # Set the terraform required version
  required_version = ">= 1.0.0"

  # Register common providers
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.34.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "2.13.2"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.28.1"
    }
  }

  # Persist state in a storage account
  #   backend "azurerm" {
  #   }
}

# Configure the Azure Provider
provider "azurerm" {
  skip_provider_registration = true
  features {}
}

# Data

# Provides client_id, tenant_id, subscription_id and object_id variables
provider "azuread" {
  tenant_id = data.azurerm_client_config.current.tenant_id
}

data "azurerm_client_config" "current" {}


data "azuread_user" "current_user" {
  user_principal_name = var.user_principal_name
}
