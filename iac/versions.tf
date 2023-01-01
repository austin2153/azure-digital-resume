# Terraform Block
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.37.0"
    }
    
  }

  cloud {
    organization = "ACLABORG"
    workspaces {
      name = "aclab-tf-digital-resume"
    }
  }
  
}
