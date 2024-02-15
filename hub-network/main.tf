resource "azapi_resource" "rg" {
  type     = "Microsoft.Resources/resourceGroups@2023-07-01"
  name     = "rg-peerresync-hub"
  location = "northeurope"
}

resource "azapi_resource" "vnet_hub" {
  type      = "Microsoft.Network/virtualNetworks@2023-09-01"
  name      = "vnet-hub"
  parent_id = azapi_resource.rg.id
  location  = azapi_resource.rg.location
  body = jsonencode({
    properties = {
      addressSpace = {
        addressPrefixes = ["192.168.0.0/16", "172.16.0.0/16"]
      }
    }
  })
}
