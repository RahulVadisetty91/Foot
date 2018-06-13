output "dwh_rg" {
  value = "${azurerm_resource_group.DataWarehouse.name}"
}

output "sqlservername" {
  value = "${azurerm_sql_database.DataWarehouse.server_name}"
}

output "fqdn" {
  value = "${azurerm_sql_server.DataWarehouse.fully_qualified_domain_name}"
}

# output "dwh_rg" {
#   value = "${module.dwh.dwh_rg}"
# }
# output "sqlservername" {
#   value = "${module.dwh.sqlservername}"
# }
# output "fqdn" {
#   value = "${module.dwh.fqdn}"
# }

