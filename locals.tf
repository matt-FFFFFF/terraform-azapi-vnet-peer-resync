locals {
  hub_vnet_resource_id = "/subscriptions/d5ffd04f-25c8-4494-a5de-4e1c707bf600/resourceGroups/rg-peerresync-hub/providers/Microsoft.Network/virtualNetworks/vnet-hub"
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
