provider "azurerm" {
  features {}



  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id

}
# Resource Group
resource "azurerm_resource_group" "TestRG" {
  name     = var.resource_group_name
  location = var.location
}

# Storage Account
resource "azurerm_storage_account" "testsa01" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.TestRG.name
  location                 = azurerm_resource_group.TestRG.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Key Vault
resource "azurerm_key_vault" "testkv01" {
  name                        = var.key_vault_name
  location                    = azurerm_resource_group.TestRG.location
  resource_group_name         = azurerm_resource_group.TestRG.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = ["Get", "List", "Set"]
  }
}

# Key Vault Secret
resource "azurerm_key_vault_secret" "app_secret" {
  name         = "AppPassword"
  value        = var.admin_password
  key_vault_id = azurerm_key_vault.testkv01.id
}

# Get current client info
data "azurerm_client_config" "Novasphere" {}

# Virtual Network
resource "azurerm_virtual_network" "testvnet01" {
  name                = "app-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.TestRG.location
  resource_group_name = azurerm_resource_group.TestRG.name
}

# Subnet
resource "azurerm_subnet" "testsubnet01" {
  name                 = "app-subnet"
  resource_group_name  = azurerm_resource_group.TestRG.name
  virtual_network_name = azurerm_virtual_network.testvnet01.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Network Security Group
resource "azurerm_network_security_group" "testnsg01" {
  name                = "app-nsg"
  location            = azurerm_resource_group.TestRG.location
  resource_group_name = azurerm_resource_group.TestRG.name

  security_rule {
    name                       = "AllowHTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowSSH"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Public IP
resource "azurerm_public_ip" "tst-public_ip" {
  name                = "app-public-ip"
  location            = azurerm_resource_group.TestRG.location
  resource_group_name = azurerm_resource_group.TestRG.name
  allocation_method   = "Dynamic"
}

# Network Interface
resource "azurerm_network_interface" "test-nic" {
  name                = "app-nic"
  location            = azurerm_resource_group.TestRG.location
  resource_group_name = azurerm_resource_group.TestRG.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.testsubnet01.id
    private_ip_address_allocation = "Static"
    public_ip_address_id          = azurerm_public_ip.tst-public_ip.id

  }

}

#Network Association
resource "azurerm_network_interface_security_group_association" "test-nic-nsg" {
  network_interface_id      = azurerm_network_interface.test-nic.id
  network_security_group_id = azurerm_network_security_group.testnsg01.id
}

# Linux VM
resource "azurerm_linux_virtual_machine" "vm" {
  name                = "app-vm"
  resource_group_name = azurerm_resource_group.TestRG.name
  location            = azurerm_resource_group.TestRG.location
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password

  network_interface_ids = [azurerm_network_interface.test-nic.id]

  os_disk {
    name                 = "app-os-disk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  custom_data = base64encode(<<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y apache2
              echo "<h1>Hello from Azure VM with Storage and Key Vault</h1>" > /var/www/html/index.html
              systemctl start apache2
              systemctl enable apache2
              EOF
  )
}





