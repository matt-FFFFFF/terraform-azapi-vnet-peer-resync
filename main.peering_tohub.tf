# azapi_resource.vnet_peering_tohub creates a virtual network peering from the spoke to the hub.
resource "azapi_resource" "vnet_peering_tohub" {
  type      = "Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-09-01"
  name      = "vnet-peering-tohub"
  parent_id = azapi_resource.vnet_spoke.id
  body      = local.vnet_peering_tohub_body
}

# data.azapi_resource.vnet_hub gets the remote virtual hub from Azure and exports the addressPrefixes property.
data "azapi_resource" "vnet_hub" {
  type                   = "Microsoft.Network/virtualNetworks@2023-09-01"
  resource_id            = local.hub_vnet_resource_id
  response_export_values = ["properties.addressSpace.addressPrefixes"]
}

# terraform_data.vnet_hub_address_space gets the addressPrefixes property from data.azapi_resource.vnet_hub
# and stored it as a managed resource so that we can use it in replace_triggered_by.
resource "terraform_data" "vnet_hub_address_space" {
  input = jsondecode(data.azapi_resource.vnet_hub.output).properties.addressSpace.addressPrefixes
}

# azapi_resource_action.vnet_peering_tohub_sync is triggered by terraform_data.vnet_hub_address_space
# resource, and it updates the virtual network peering to sync the remote address space.
resource "azapi_resource_action" "vnet_peering_tohub_sync" {
  # https://github.com/Azure/azure-rest-api-specs/blob/79e4e0c9f8e1c134bcda069fc7994fd99599ccdc/specification/network/resource-manager/Microsoft.Network/stable/2023-09-01/virtualNetwork.json#L1047-L1058
  resource_id = "${azapi_resource.vnet_peering_tohub.id}?syncRemoteAddressSpace=true"
  type        = "Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-09-01"
  method      = "PUT"
  body        = local.vnet_peering_tohub_body
  lifecycle {
    replace_triggered_by = [terraform_data.vnet_hub_address_space]
  }
}
