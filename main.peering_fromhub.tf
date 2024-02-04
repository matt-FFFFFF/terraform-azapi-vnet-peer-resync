# azapi_resource.vnet_peering_fromhub creates a virtual network peering from the hub to the spoke.
resource "azapi_resource" "vnet_peering_fromhub" {
  type      = "Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-09-01"
  name      = "vnet-peering-fromhub"
  parent_id = local.hub_vnet_resource_id
  body      = local.vnet_peering_fromhub_body
}

# azapi_resource_action.vnet_peering_fromhub_data is triggered by the spoke network being updated.
# It gets the peeringSyncLevel property from the virtual network peering.
resource "azapi_resource_action" "vnet_peering_fromhub_data" {
  resource_id            = azapi_resource.vnet_peering_fromhub.id
  type                   = "Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-09-01"
  response_export_values = ["properties.peeringSyncLevel"]
  method                 = "GET"
  lifecycle {
    replace_triggered_by = [azapi_resource.vnet_spoke]
  }
}

# terraform_data.vnet_peering_fromhub_sync_required is set to either true of false, depending on whether the
# peeringSyncLevel property is LocalNotInSync.
resource "terraform_data" "vnet_peering_fromhub_sync_required" {
  input = jsondecode(azapi_resource_action.vnet_peering_fromhub_data.output).properties.peeringSyncLevel == "LocalNotInSync"
}

# azapi_resource_action.vnet_peering_fromhub_sync is triggered by terraform_data.vnet_peering_fromhub_sync_required resource
# and it updates the virtual network peering to sync the remote address space.
resource "azapi_resource_action" "vnet_peering_fromhub_sync" {
  resource_id = "${azapi_resource.vnet_peering_fromhub.id}?syncRemoteAddressSpace=true"
  type        = "Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-09-01"
  method      = "PUT"
  body        = local.vnet_peering_fromhub_body
  lifecycle {
    replace_triggered_by = [terraform_data.vnet_peering_fromhub_sync_required]
  }
}
