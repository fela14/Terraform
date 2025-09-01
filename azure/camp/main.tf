terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.1.0"
    }
  }

  required_version = ">= 1.3.0"
}

provider "azurerm" {
  features {}
  use_cli         = true
  subscription_id = "a5223039-b4c4-4d3f-bff3-85d05005df44"
}

# Resource Group
resource "azurerm_resource_group" "ntc_rg" {
  name     = "ntc_rg"
  location = "West Europe"

  tags = {
    environment = "dev"
  }
}

# Virtual Network
resource "azurerm_virtual_network" "ntc_vn" {
  name                = "ntc_network"
  resource_group_name = azurerm_resource_group.ntc_rg.name
  location            = azurerm_resource_group.ntc_rg.location
  address_space       = ["10.123.0.0/16"]

  tags = {
    environment = "dev"
  }
}

# Subnet
resource "azurerm_subnet" "ntc_subnet" {
  name                 = "ntc_subnet"
  resource_group_name  = azurerm_resource_group.ntc_rg.name
  virtual_network_name = azurerm_virtual_network.ntc_vn.name
  address_prefixes     = ["10.123.1.0/24"]
}

# Network Security Group
resource "azurerm_network_security_group" "ntc_sg" {
  name                = "ntc_sg"
  location            = azurerm_resource_group.ntc_rg.location
  resource_group_name = azurerm_resource_group.ntc_rg.name

  tags = {
    environment = "dev"
  }

  # SSH rule
  security_rule {
    name                       = "Allow_SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # HTTP rule
  security_rule {
    name                       = "Allow_HTTP"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Associate NSG with Subnet
resource "azurerm_subnet_network_security_group_association" "ntc_sga" {
  subnet_id                 = azurerm_subnet.ntc_subnet.id
  network_security_group_id = azurerm_network_security_group.ntc_sg.id
}

# Public IP
resource "azurerm_public_ip" "ntc_ip" {
  name                = "ntc_ip"
  resource_group_name = azurerm_resource_group.ntc_rg.name
  location            = azurerm_resource_group.ntc_rg.location
  allocation_method   = "Dynamic"

  tags = {
    environment = "dev"
  }
}

# Network Interface
resource "azurerm_network_interface" "ntc_nic" {
  name                = "ntc_nic"
  location            = azurerm_resource_group.ntc_rg.location
  resource_group_name = azurerm_resource_group.ntc_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.ntc_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ntc_ip.id
  }

  tags = {
    environment = "dev"
  }
}

# Linux VM
resource "azurerm_linux_virtual_machine" "ntc_vm" {
  name                = "ntc_vm"
  resource_group_name = azurerm_resource_group.ntc_rg.name
  location            = azurerm_resource_group.ntc_rg.location
  size                = "Standard_B1s"
  admin_username      = "azureuser"

  network_interface_ids = [
    azurerm_network_interface.ntc_nic.id
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "20_04-lts"
    version   = "latest"
  }

  # Custom script to install Docker
  custom_data = filebase64("customdata.tpl")

  tags = {
    environment = "dev"
  }
}
