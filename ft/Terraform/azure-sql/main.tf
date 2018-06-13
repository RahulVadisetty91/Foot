resource "azurerm_sql_firewall_rule" "terraform-test" {
    name = "FirewallRule1"
    resource_group_name = "DAP-DEV-rahul-test"
    server_name = "${azurerm_sql_server.terraform-test.name}"
    start_ip_address = "0.0.0.0"
    end_ip_address = "255.255.255.255"
}

resource "azurerm_sql_server" "terraform-test" {
    name = "terraform-test-sql-server2"
    resource_group_name = "DAP-DEV-rahul-test"
    location = "East us 2"
    version = "12.0"
    administrator_login = "dbloginuser"
    administrator_login_password = "SuperSecretPassword123"
}
resource "azurerm_sql_database" "terraform-test" {
    name = "adwtestdb"
    resource_group_name = "DAP-DEV-rahul-test"
    server_name = "${azurerm_sql_server.terraform-test.name}"
    location = "East us 2"
    edition = "DataWarehouse"
    requested_service_objective_name = "DW100"
}