terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.1.0"
    }
  }

  required_version = ">= 1.3.0"
}

provider "azurerm" {
  features {}
  use_cli         = true
  subscription_id = "a5223039-b4c4-4d3f-bff3-85d05005df44"
}


resource "azurerm_resource_group" "ntc_rg" {
  name     = "ntc-resources"
  location = "West Europe"

  tags = {
    environment = "dev"
  }
}
