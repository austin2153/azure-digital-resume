# Provider Block
provider "azurerm" {
  features {}
}

# Create Resource Group
resource "azurerm_resource_group" "resource_group" {
  name     = var.resource_group_name
  location = var.location
}

# Create Azure Storage account
resource "azurerm_storage_account" "storage_account" {
  name                = var.storage_account_name
  resource_group_name = azurerm_resource_group.resource_group.name

  location                 = var.location
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_account_replication_type
  account_kind             = var.storage_account_kind

  static_website {
    index_document     = var.static_website_index_document
    error_404_document = var.static_website_error_404_document
  }

  tags = {
    environment = "production"
    purpose     = "blog"
  }

}

# Add staging content index.html to blob storage
resource "azurerm_storage_blob" "static-web-demo-storage-blob" {
  name                   = var.static_website_index_document
  storage_account_name   = azurerm_storage_account.storage_account.name
  storage_container_name = "$web"
  type                   = "Block"
  content_type           = "text/html"
  source_content         = var.source_content
}

# CDN Profile
resource "azurerm_cdn_profile" "cdn_profile" {
  name                = var.cdnprofile_name
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  sku                 = var.cdnprofile_sku
}

# CDN Endpoint
resource "azurerm_cdn_endpoint" "static-web-endpoint" {
  name                = var.cdn_endpoint_name
  profile_name        = azurerm_cdn_profile.cdn_profile.name
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  origin_host_header = azurerm_storage_account.storage_account.primary_web_host
  is_https_allowed = true

  origin {
    name      = "staticwebdemoportal"
    host_name = azurerm_storage_account.storage_account.primary_web_host
  }

  # Rules for Rules Engine
  delivery_rule {
    name = "spaURLReroute"
    order = "1"

    url_file_extension_condition {
      operator = "LessThan"
      match_values = ["1"]
    }

    url_rewrite_action {
      destination             = "/index.html"
      preserve_unmatched_path = "false"
      source_pattern          = "/"
    }
  }

  # force any http traffic to re-route to https
  delivery_rule {
    name = "EnforceHTTPS"
    order = "2"

    request_scheme_condition {
      operator = "Equal"
      match_values = ["HTTP"]
    }

    url_redirect_action {
      redirect_type = "Found"
      protocol = "Https"
    }
  }

}

# Create a dns zone
resource "azurerm_dns_zone" "dns_zone" {
  name                = var.domain_name
  resource_group_name = azurerm_resource_group.resource_group.name
}

resource "azurerm_dns_a_record" "a_record" {
  name                = "@"
  zone_name           = azurerm_dns_zone.dns_zone.name
  resource_group_name = azurerm_resource_group.resource_group.name
  ttl                 = 300
  target_resource_id  = azurerm_cdn_endpoint.static-web-endpoint.id
}

# Create a cname record in dns zone
resource "azurerm_dns_cname_record" "cname_record" {
  name                = "www"
  zone_name           = azurerm_dns_zone.dns_zone.name
  resource_group_name = azurerm_dns_zone.dns_zone.resource_group_name
  ttl                 = 3600
  target_resource_id  = azurerm_cdn_endpoint.static-web-endpoint.id
}

# Create a cname record in dns zone
resource "azurerm_dns_cname_record" "cname_cdnverify" {
  name                = "cdnverify"
  zone_name           = azurerm_dns_zone.dns_zone.name
  resource_group_name = azurerm_dns_zone.dns_zone.resource_group_name
  ttl                 = 3600 
  record              = "cdnverify.${azurerm_cdn_endpoint.static-web-endpoint.name}.net"
}

# Create a cname record in dns zone
resource "azurerm_dns_cname_record" "cname_cdnverify_www" {
  name                = "cdnverify.www"
  zone_name           = azurerm_dns_zone.dns_zone.name
  resource_group_name = azurerm_dns_zone.dns_zone.resource_group_name
  ttl                 = 3600 
  record              = "cdnverify.${azurerm_cdn_endpoint.static-web-endpoint.name}.net"
}

# # add custom dns name to cdn endpoint
# resource "azurerm_cdn_endpoint_custom_domain" "custom_domain" {
#   name            = "customdomain"
#   cdn_endpoint_id = azurerm_cdn_endpoint.static-web-endpoint.id
#   host_name       = "${azurerm_dns_cname_record.cname_record.name}.${azurerm_dns_zone.dns_zone.name}"

#   timeouts {
#     create = "12h"
#     update = "12h"
#     delete = "2h"
#   }

#   cdn_managed_https {
#     certificate_type = "Dedicated"
#     protocol_type = "ServerNameIndication"
#     tls_version = "TLS12"
#   }
# }

# Cosmos DB

# resource "azurerm_cosmosdb_account" "cosmosdb_account" {
#   name                      = var.cosmosdb_account_name
#   location                  = var.location
#   resource_group_name       = azurerm_resource_group.resource_group.name
#   offer_type                = "Standard"
#   kind                      = "GlobalDocumentDB"
#   enable_automatic_failover = false
#   enable_free_tier = true 
#   geo_location {
#     location          = var.location
#     failover_priority = 0
#   }
#   consistency_policy {
#     consistency_level       = "BoundedStaleness"
#     max_interval_in_seconds = 300
#     max_staleness_prefix    = 100000
#   }
#   depends_on = [
#     azurerm_resource_group.example
#   ]
# }

# resource "azurerm_cosmosdb_sql_database" "sql_database" {
#   name                = var.cosmosdb_sqldb_name
#   resource_group_name = azurerm_resource_group.resource_group.name
#   account_name        = azurerm_cosmosdb_account.cosmosdb_account.name
#   throughput          = var.throughput
# }

# resource "azurerm_cosmosdb_sql_container" "example" {
#   name                  = var.sql_container_name
#   resource_group_name   = azurerm_resource_group.resource_group.name
#   account_name          = azurerm_cosmosdb_account.cosmosdb_account.name
#   database_name         = azurerm_cosmosdb_sql_database.sql_database.name
#   partition_key_path    = "/definition/id"
#   partition_key_version = 1
#   throughput            = var.throughput

#   indexing_policy {
#     indexing_mode = "consistent"

#     included_path {
#       path = "/*"
#     }

#     included_path {
#       path = "/included/?"
#     }

#     excluded_path {
#       path = "/excluded/?"
#     }
#   }

#   unique_key {
#     paths = ["/definition/idlong", "/definition/idshort"]
#   }
# }