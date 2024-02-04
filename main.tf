resource "azapi_resource" "rg" {
  type     = "Microsoft.Resources/resourceGroups@2023-07-01"
  name     = "rg-peerresync-spoke"
  location = "northeurope"
}

data "azapi_resource" "vnet_hub" {
  type                   = "Microsoft.Network/virtualNetworks@2023-09-01"
  resource_id            = local.hub_vnet_resource_id
  response_export_values = ["properties.addressSpace.addressPrefixes"]
}

resource "terraform_data" "vnet_hub_address_space" {
  input = jsondecode(data.azapi_resource.vnet_hub.output).properties.addressSpace.addressPrefixes
}

resource "azapi_resource" "vnet_spoke" {
  type      = "Microsoft.Network/virtualNetworks@2023-09-01"
  name      = "vnet-spoke"
  parent_id = azapi_resource.rg.id
  location  = azapi_resource.rg.location
  body = jsonencode({
    properties = {
      addressSpace = {
        addressPrefixes = ["10.0.0.0/24", "10.0.1.0/24"]
      }
    }
  })
}

resource "azapi_resource" "vnet_peering_tohub" {
  type      = "Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-09-01"
  name      = "vnet-peering-tohub"
  parent_id = azapi_resource.vnet_spoke.id
  body = jsonencode({
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
}

resource "azapi_resource_action" "vnet_peering_tohub_data" {
  resource_id            = azapi_resource.vnet_peering_tohub.id
  type                   = "Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-09-01"
  response_export_values = ["properties.peeringSyncLevel"]
  method                 = "GET"
  lifecycle {
    replace_triggered_by = [terraform_data.vnet_hub_address_space]
  }
}

resource "terraform_data" "vnet_peering_tohub_syncrequired" {
  input = jsondecode(azapi_resource_action.vnet_peering_tohub_data.output).properties.peeringSyncLevel == "LocalNotInSync"
}

resource "azapi_resource_action" "vnet_peering_tohub_sync" {
  # https://github.com/Azure/azure-rest-api-specs/blob/79e4e0c9f8e1c134bcda069fc7994fd99599ccdc/specification/network/resource-manager/Microsoft.Network/stable/2023-09-01/virtualNetwork.json#L1047-L1058
  resource_id = "${azapi_resource.vnet_peering_tohub.id}?syncRemoteAddressSpace=true"
  type        = "Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-09-01"
  method      = "PUT"
  body = jsonencode({
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
  lifecycle {
    replace_triggered_by = [terraform_data.vnet_peering_tohub_syncrequired]
  }
}



resource "azapi_resource" "vnet_peering_fromhub" {
  type      = "Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-09-01"
  name      = "vnet-peering-fromhub"
  parent_id = local.hub_vnet_resource_id
  body = jsonencode({
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

resource "azapi_resource_action" "vnet_peering_fromhub_data" {
  resource_id            = azapi_resource.vnet_peering_fromhub.id
  type                   = "Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-09-01"
  response_export_values = ["properties.peeringSyncLevel"]
  method                 = "GET"
  lifecycle {
    replace_triggered_by = [azapi_resource.vnet_spoke]
  }
}

resource "terraform_data" "vnet_peering_fromhub_syncrequired" {
  input = jsondecode(azapi_resource_action.vnet_peering_fromhub_data.output).properties.peeringSyncLevel == "LocalNotInSync"
}

resource "azapi_resource_action" "vnet_peering_fromhub_sync" {
  resource_id = "${azapi_resource.vnet_peering_fromhub.id}?syncRemoteAddressSpace=true"
  type        = "Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-09-01"
  method      = "PUT"
  body = jsonencode({
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
  lifecycle {
    replace_triggered_by = [terraform_data.vnet_peering_fromhub_syncrequired]
  }
}
