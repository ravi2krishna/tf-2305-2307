# Virtual Network
resource "azurerm_virtual_network" "ecomm-vnet" {
  name                = "ecomm-network"
  location            = azurerm_resource_group.tf-ecomm-rg.location
  resource_group_name = azurerm_resource_group.tf-ecomm-rg.name
  address_space       = ["10.0.0.0/16"]
  tags = {
    env = "prod"
  }
}

# Public Subnet
resource "azurerm_subnet" "ecomm-pub-sn" {
  name                 = "ecomm-web-subnet"
  resource_group_name  = azurerm_resource_group.tf-ecomm-rg.name
  virtual_network_name = azurerm_virtual_network.ecomm-vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Private Subnet
resource "azurerm_subnet" "ecomm-pvt-sn" {
  name                 = "ecomm-database-subnet"
  resource_group_name  = azurerm_resource_group.tf-ecomm-rg.name
  virtual_network_name = azurerm_virtual_network.ecomm-vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Public Network Secuirty Group
resource "azurerm_network_security_group" "ecomm-pub-nsg" {
  name                = "ecomm-web-nsg"
  location            = azurerm_resource_group.tf-ecomm-rg.location
  resource_group_name = azurerm_resource_group.tf-ecomm-rg.name

  security_rule {
    name                       = "ssh"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

    security_rule {
    name                       = "http"
    priority                   = 1100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    env = "prod"
  }
}

# Private Network Secuirty Group
resource "azurerm_network_security_group" "ecomm-pvt-nsg" {
  name                = "ecomm-database-nsg"
  location            = azurerm_resource_group.tf-ecomm-rg.location
  resource_group_name = azurerm_resource_group.tf-ecomm-rg.name

  security_rule {
    name                       = "ssh"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "10.0.0.0/16"
    destination_address_prefix = "*"
  }

    security_rule {
    name                       = "postgres"
    priority                   = 1100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5432"
    source_address_prefix      = "10.0.0.0/16"
    destination_address_prefix = "*"
  }

  tags = {
    env = "prod"
  }
}

# Public NSG Association
resource "azurerm_subnet_network_security_group_association" "ecomm-pub-nsg-a" {
  subnet_id                 = azurerm_subnet.ecomm-pub-sn.id
  network_security_group_id = azurerm_network_security_group.ecomm-pub-nsg.id
}

# Private NSG Association
resource "azurerm_subnet_network_security_group_association" "ecomm-pvt-nsg-a" {
  subnet_id                 = azurerm_subnet.ecomm-pvt-sn.id
  network_security_group_id = azurerm_network_security_group.ecomm-pvt-nsg.id
}

# Public IP for VM
resource "azurerm_public_ip" "ecomm-pip" {
  name                = "ecomm-web-pip"
  resource_group_name = azurerm_resource_group.tf-ecomm-rg.name
  location            = azurerm_resource_group.tf-ecomm-rg.location
  allocation_method   = "Static"

  tags = {
    env = "prod"
  }
}

# Public NIC
resource "azurerm_network_interface" "ecomm-pub-nic" {
  name                = "ecomm-web-nic"
  location            = azurerm_resource_group.tf-ecomm-rg.location
  resource_group_name = azurerm_resource_group.tf-ecomm-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.ecomm-pub-sn.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.ecomm-pip.id
  }
}