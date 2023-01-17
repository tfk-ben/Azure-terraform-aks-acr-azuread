terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.33.0"
    }

      azuread = {
      source = "hashicorp/azuread"
      version = "2.32.0"
    }

  }
}

provider "azurerm" {
  features {}
}

provider "azuread" {
  # Configuration options
}


resource "azurerm_resource_group" "aks-rg" {
  name     = var.resource_group_name
  location = var.location
}

# Create Azure AD Group in Active Directory for AKS Admins
resource "azuread_group" "aks_administrators" {
  display_name        = "${azurerm_resource_group.aks-rg.name}-administrators"
  security_enabled = true
}



resource "azurerm_role_assignment" "role_acrpull" {
  scope                            = azurerm_container_registry.acr.id
  role_definition_name             = "AcrPull"
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity.0.object_id
  skip_service_principal_aad_check = true
}

resource "azurerm_container_registry" "acr" {
  name                = "myaskrepo"
  resource_group_name = azurerm_resource_group.aks-rg.name
  location            = azurerm_resource_group.aks-rg.location
  sku                 = "Standard"
  admin_enabled       = false
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${azurerm_resource_group.aks-rg.name}-aks-cluser"
  kubernetes_version  = var.kubernetes_version
  location            = azurerm_resource_group.aks-rg.location
  resource_group_name = azurerm_resource_group.aks-rg.name
  dns_prefix          = "mycluser"

  default_node_pool {
    name                = "aksnodepool"
    vm_size             = "Standard_DS2_v2"
    type                = "VirtualMachineScaleSets"
    #zones  = [1, 2, 3]
    node_count          = var.system_node_count
    enable_auto_scaling = false
    #if true :
    #min_count = 1    
    #max_count = 5

  }

linux_profile {
  admin_username = "ubuntu"
  ssh_key {
      key_data = file(var.ssh_key)
  }
}

azure_active_directory_role_based_access_control {
    managed = true
    admin_group_object_ids = [azuread_group.aks_administrators.id] #object_id
    
}



# Identity (System Assigned or Service Principal)
  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "kubenet" 
  }
}




# get the kubeconfig 
# resource "local_file" "kubeconfig" {
#   depends_on   = [azurerm_kubernetes_cluster.aks]
#   filename     = "kubeconfig"
#   content      = azurerm_kubernetes_cluster.aks.kube_config_raw
# }


