terraform {
  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "~> 1.11"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.10"
    }
  }
}
