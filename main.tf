resource "azapi_resource" "rg" {
  type     = "Microsoft.Resources/resourceGroups@2023-07-01"
  name     = "rg-peerresync-spoke"
  location = "northeurope"
}

resource "azapi_resource" "vnet_spoke" {
  type      = "Microsoft.Network/virtualNetworks@2023-09-01"
  name      = "vnet-spoke"
  parent_id = azapi_resource.rg.id
  location  = azapi_resource.rg.location
  body = jsonencode({
    properties = {
      addressSpace = {
        addressPrefixes = ["10.0.0.0/24", ]
      }
    }
  })
}
