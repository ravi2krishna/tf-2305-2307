resource "azurerm_resource_group" "tf-ecomm-rg" {
  name     = "tf-2305-2307"
  location = "East US"
    tags = {
    env = "prod"
  }
}