locals {
  hub_vnet_resource_id = "/subscriptions/57934baa-70ec-4d1a-95e0-3799a838811f/resourceGroups/rg-peerresync-hub/providers/Microsoft.Network/virtualNetworks/vnet-hub"
  vnet_peering_tohub_body = jsonencode({
    properties = {
      allowVirtualNetworkAccess = true,
      allowForwardedTraffic     = true,
      allowGatewayTransit       = false,
      useRemoteGateways         = false,
      remoteVirtualNetwork = {
        id = local.hub_vnet_resource_id
      }
    }
  })

  vnet_peering_fromhub_body = jsonencode({
    properties = {
      allowVirtualNetworkAccess = true,
      allowForwardedTraffic     = true,
      allowGatewayTransit       = false,
      useRemoteGateways         = false,
      remoteVirtualNetwork = {
        id = azapi_resource.vnet_spoke.id
      }
    }
  })
}
