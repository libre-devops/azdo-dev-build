variable "environment" {
  default     = "prd"
  type        = string
  description = "Used as an alterative to terraform.workspace"
}

locals {

  names = {
    key0 = var.environment         // prd
    key1 = "${var.environment}-vm" // prd-vm
    key2 = "prd-biscuit"
    key3 = "tst_pizza"
  }
}

resource "azurerm_resource_group" "test_rg" {
  for_each = {
    for key, value in local.names : key => value
    if length(regexall("${var.environment}-", value)) > 0 // Checks the values of the map called local.names, if the any value of that map contains the name "prd-" followed by anything else, then make a resource group for it, with that value of the map as the name of the resource group.  If no match is found, do nothing.
  }
  location = local.location
  name     = each.value // makes 2 rgs, prd-vm and prd-biscuit
}

output "rg_name" {
  value = azurerm_resource_group.test_rg.*
}

output "first_key" {
  value = lookup(azurerm_resource_group.test_rg.*[1], "key0", 0)
}

#module "vnet" {
#  source = "./test-modules/terraform-azurerm-network"
#
#  rg_name         = azurerm_resource_group.test_rg[each.key].name
#  location        = local.location
#  address_space   = ["10.0.0.0/16"]
#  subnet_prefixes = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
#  subnet_names    = ["subnet1", "subnet2", "subnet3"]
#
#  subnet_service_endpoints = {
#    subnet2 = ["Microsoft.Storage", "Microsoft.Sql"],
#    subnet3 = ["Microsoft.AzureActiveDirectory"]
#  }
#
#  tags = {
#    environment = "dev"
#    costcenter  = "it"
#  }
#
#}