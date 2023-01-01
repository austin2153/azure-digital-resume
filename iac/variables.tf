# Input variable definitions
variable "location" {
  description = "The Azure Region in which all resources groups should be created."
  type        = string
}
variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}
variable "storage_account_name" {
  description = "The name of the storage account"
  type        = string
}
variable "storage_account_tier" {
  description = "Storage Account Tier"
  type        = string
}
variable "storage_account_replication_type" {
  description = "Storage Account Replication Type"
  type        = string
}
variable "storage_account_kind" {
  description = "Storage Account Kind"
  type        = string
}
variable "static_website_index_document" {
  description = "static website index document"
  type        = string
}
variable "static_website_error_404_document" {
  description = "static website error 404 document"
  type        = string
}
variable "cdnprofile_name" {
  description = "CDN Profile Name"
  type        = string
}
variable "cdnprofile_sku" {
  description = "CDN Profile SKU"
  type        = string
}
variable "cdn_endpoint_name" {
  description = "CDN Endpoint name"
  type        = string
}
variable "source_content" {
  description = "This is the source content for the static website"
}
variable "domain_name" {
  description = "Name of custom domain"
}

// Cosmos DB

# variable "cosmosdb_account_name" {
#   type        = string
#   description = "Cosmos db account name"
# }


# variable "cosmosdb_sqldb_name" {
#   type        = string
#   description = "value"
# }

# variable "sql_container_name" {
#   type        = string
#   description = "SQL API container name."
# }

# variable "throughput" {
#   type        = number
#   description = "Cosmos db database throughput"
#   validation {
#     condition     = var.throughput >= 400 && var.throughput <= 1000000
#     error_message = "Cosmos db manual throughput should be equal to or greater than 400 and less than or equal to 1000000."
#   }
#   validation {
#     condition     = var.throughput % 100 == 0
#     error_message = "Cosmos db throughput should be in increments of 100."
#   }
# }