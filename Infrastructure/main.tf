# Define provider
terraform {
  backend "azurerm" {
  }
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.109.0"
    }
  }
}

provider "azurerm" {
  features{}
  skip_provider_registration = true
}

locals {
    default_tags = merge(var.default_tags)
}

# Define a variable to hold resource group parameters
variable "resource_groups" {
  type = map(object({
    location = string
  }))
  default = {
    "rg1" = {
      location = "West US"
    }
    "rg2" = {
      location = "East US"
    }
  }
}

variable "default_tags" {
    type = map(any)
    default = {
        "Business Unit" = "Urban Devops"
        "Managed By" = "Urban Devops"
        "Managed Via" = "Terraform"
    }
}


# Create multiple resource groups using a for_each loop
resource "azurerm_resource_group" "example" {
  for_each = var.resource_groups

  name     = each.key
  location = each.value.location
  tags = merge(local.default_tags,
    {
        "Owner" = "Venkatesh J"
    })
}

# Outputs to showcase created resource groups
output "resource_group_ids" {
  value = { 
    for rg in azurerm_resource_group.example : rg.name => rg.id 
  }
}

output "resource_group_names" {
  value = [for rg in azurerm_resource_group.example : rg.name]
}