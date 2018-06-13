# Configure the Azure Provider
provider "azurerm" {
  subscription_id = "${var.subscription_id}"

  client_id     = "${var.client_id}"
  client_secret = "${var.client_secret}"
  tenant_id     = "${var.tenant_id}"
}

resource "azurerm_resource_group" "DataWarehouse" {
  name     = "${var.product_key}-${var.deploy_scenario}-${var.stack_aggregation}-dwh-${var.dwh_name}"
  location = "${var.dwh_region}"

  tags {
    Product             = "${var.product_key}"
    ApplicationName     = "${var.application_name}"
    CostCenter          = "${var.costcenter}"
    DeployScenario      = "${var.deploy_scenario}"
    StackAggregationTag = "${var.stack_aggregation}"
    created_by          = "${var.created_by}"
    Environment         = "${var.environment}"
  }
}

resource "azurerm_sql_firewall_rule" "DataWarehouse" {
  name                = "${var.dwh_name}FirewallRule1"
  resource_group_name = "${azurerm_resource_group.DataWarehouse.name}"
  server_name         = "${azurerm_sql_server.DataWarehouse.name}"
  start_ip_address    = "10.0.0.0"
  end_ip_address      = "10.255.255.255"
}

resource "azurerm_sql_server" "DataWarehouse" {
  name                         = "${var.dwh_name}sql"
  resource_group_name          = "${azurerm_resource_group.DataWarehouse.name}"
  version                      = "${var.sql_version}"
  location                     = "${var.dwh_region}"
  administrator_login          = "${var.dwh_admin}"
  administrator_login_password = "${var.dwh_pwd}"
}

resource "azurerm_sql_database" "DataWarehouse" {
  name                             = "${var.dwh_name}db"
  resource_group_name              = "${azurerm_resource_group.DataWarehouse.name}"
  server_name                      = "${azurerm_sql_server.DataWarehouse.name}"
  location                         = "${var.dwh_region}"
  edition                          = "Basic"
  requested_service_objective_name = "${var.sql_db_service_level}"
}

# module "dwh" {
#   source               = "https://azu-tartifact.corp.footlocker.net/artifactory/fl-dataplatform-maven-releases/com/footlocker/platform/terraform/datawarehouse-module/develop/datawarehouse-module-develop.zip"
#   product_key          = "${var.product_key}"
#   application_name     = "${var.application_name}"
#   costcenter           = "${var.costcenter}"
#   deploy_scenario      = "${var.deploy_scenario}"
#   stack_aggregation    = "${var.stack_aggregation}"
#   created_by           = "${var.created_by}"
#   environment          = "${var.environment}"
#   dwh_region           = "${var.region}"
#   dwh_name             = "${var.dwh_name}"
#   dwh_admin            = "${var.dwh_admin}"
#   dwh_pwd              = "${var.dwh_pwd}"
#   sql_db_service_level = "${var.sql_db_service_level}"
#   sql_version          = "${var.sql_version}"
# }

