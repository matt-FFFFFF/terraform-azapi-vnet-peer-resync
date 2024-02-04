output "vnet_peering_tohub_resource_id" {
  value = azapi_resource.vnet_peering_tohub.id
}

output "vnet_peering_fromhub_resource_id" {
  value = azapi_resource.vnet_peering_fromhub.id
}

output "peering_sync_tohub_required" {
  value = terraform_data.vnet_peering_tohub_syncrequired.input
}

output "peering_sync_fromhub_required" {
  value = terraform_data.vnet_peering_fromhub_syncrequired.input
}
