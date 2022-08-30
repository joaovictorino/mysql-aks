terraform {
  required_providers {
    azurerm = {
        source = "hashicorp/azurerm"
        version = ">= 3.5.0"
    }
  }
}

provider "azurerm" {
    features {
    }
}

resource "azurerm_resource_group" "rg-mysql-test" {
    location = "eastus"
    name = "rg-mysql-test"
}

resource "azurerm_kubernetes_cluster" "aks-mysql-test" {
  name                = "aks-mysql-test"
  location            = azurerm_resource_group.rg-mysql-test.location
  resource_group_name = azurerm_resource_group.rg-mysql-test.name
  dns_prefix          = "aks-mysql-test"
  http_application_routing_enabled = true

  default_node_pool {
    name       = "default"
    node_count = 2
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Production"
  }
}

resource "azurerm_managed_disk" "disk-mysql-database" {
  name                 = "disk-mysql-database"
  location             = azurerm_resource_group.rg-mysql-test.location
  resource_group_name  = "MC_${azurerm_resource_group.rg-mysql-test.name}_${azurerm_kubernetes_cluster.aks-mysql-test.name}_${azurerm_resource_group.rg-mysql-test.location}"
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "20"

  depends_on = [ azurerm_kubernetes_cluster.aks-mysql-test ]
}

resource "azurerm_management_lock" "lock-disk-mysql-database" {
  name       = "lock-disk-mysql-database"
  scope      = azurerm_managed_disk.disk-mysql-database.id
  lock_level = "CanNotDelete"
}
