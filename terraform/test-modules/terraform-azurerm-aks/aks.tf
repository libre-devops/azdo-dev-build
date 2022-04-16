resource "azurerm_kubernetes_cluster" "main_aks" {

  name                    = lower(var.resource_name)
  kubernetes_version      = var.kubernetes_version
  location                = var.location
  resource_group_name     = var.rg_name
  dns_prefix              = var.dns_prefix
  sku_tier                = title(var.sku_tier)
  private_cluster_enabled = var.private_cluster_enabled

  linux_profile {
    admin_username = var.admin_username

    ssh_key {
      key_data = var.ssh_public_key
    }
  }

  dynamic "default_node_pool" {
    for_each = var.enable_auto_scaling == false ? ["default_node_pool_manually_scaled"] : []
    content {
      enable_auto_scaling   = var.default_node_enable_auto_scaling
      max_count             = var.default_node_agents_max_count
      min_count             = var.default_node_agents_min_count
      type                  = var.default_node_agents_type
      orchestrator_version  = var.default_node_orchestrator_version
      name                  = var.default_node_pool_name
      vm_size               = var.default_node_vm_size
      os_disk_size_gb       = var.default_node_os_disk_size_gb
      vnet_subnet_id        = var.default_node_subnet_id
      enable_node_public_ip = var.enable_node_public_ip
      availability_zones    = var.default_node_availability_zones
      node_count            = var.default_node_count
    }
  }

  dynamic "default_node_pool" {
    for_each = var.enable_auto_scaling == true ? ["default_node_pool_auto_scaled"] : []
    content {
      enable_auto_scaling   = var.default_node_enable_auto_scaling
      max_count             = var.default_node_agents_max_count
      min_count             = var.default_node_agents_min_count
      type                  = var.default_node_agents_type
      orchestrator_version  = var.default_node_orchestrator_version
      name                  = var.default_node_pool_name
      vm_size               = var.default_node_vm_size
      os_disk_size_gb       = var.default_node_os_disk_size_gb
      vnet_subnet_id        = var.default_node_subnet_id
      enable_node_public_ip = var.enable_node_public_ip
      availability_zones    = var.default_node_availability_zones
      node_count            = var.default_node_count
    }
  }

  dynamic "service_principal" {
    for_each = var.client_id != "" && var.client_secret != "" ? ["service_principal"] : []
    content {
      client_id     = var.client_id
      client_secret = var.client_secret
    }
  }

  dynamic "identity" {
    for_each = var.client_id == "" || var.client_secret == "" ? ["identity"] : []
    content {
      type                      = var.identity_type
      user_assigned_identity_id = var.user_assigned_identity_id
    }
  }

  http_application_routing_enabled = var.enable_http_application_routing
  azure_policy_enabled             = var.enable_azure_policy

  oms_agent {
    log_analytics_workspace_id = var.law_workspace_id
  }

  network_profile {
    network_plugin     = var.network_plugin
    network_policy     = var.network_policy
    dns_service_ip     = var.net_profile_dns_service_ip
    docker_bridge_cidr = var.net_profile_docker_bridge_cidr
    outbound_type      = var.net_profile_outbound_type
    pod_cidr           = var.net_profile_pod_cidr
    service_cidr       = var.net_profile_service_cidr
  }

  tags = var.tags

  timeouts {
    create = "20m"
  }
}