# azapi_resource.vnet_peering_fromhub creates a virtual network peering from the hub to the spoke.
resource "azapi_resource" "vnet_peering_fromhub" {
  type      = "Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-09-01"
  name      = "vnet-peering-fromhub"
  parent_id = local.hub_vnet_resource_id
  body      = local.vnet_peering_fromhub_body
}

# trusty time_sleep to wait for the spoke update to reconcile.
resource "time_sleep" "after_spoke_vnet_update" {
  create_duration = "20s"
  depends_on      = [azapi_resource.vnet_spoke]
  lifecycle {
    replace_triggered_by = [azapi_resource.vnet_spoke]
  }
}

# azapi_resource_action.vnet_peering_fromhub_sync is triggered by terraform_data.vnet_peering_fromhub_sync_required resource
# and it updates the virtual network peering to sync the remote address space.
resource "azapi_resource_action" "vnet_peering_fromhub_sync" {
  resource_id = "${azapi_resource.vnet_peering_fromhub.id}?syncRemoteAddressSpace=true"
  type        = "Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-09-01"
  method      = "PUT"
  body        = local.vnet_peering_fromhub_body
  lifecycle {
    replace_triggered_by = [time_sleep.after_spoke_vnet_update]
  }
}
