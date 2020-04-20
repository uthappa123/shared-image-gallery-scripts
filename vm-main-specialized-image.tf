# Configure the Azure Provider for main sub
provider "azurerm" {
  version = "~>2.0"
  features {}
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}

# Configure the Azure Provider for SIG sub
provider "azurerm" {
  alias = "sig"
  version = "~>2.0"
  features {}
  subscription_id = var.sig_subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}

# Import the Shared Image Gallery Resource
data "azurerm_shared_image_version" "sig1" {
  provider            = azurerm.sig
  name                = var.imagever
  image_name          = var.def
  gallery_name        = var.sig
  resource_group_name = var.sig_resource_group
}

# Create a Resource Group. This is the environment specific resource group
resource "azurerm_resource_group" "rg" {
  name     = "${var.resource_group}-rg"
  location = var.location

  tags = {
    environment = var.environment
    project     = var.project
    department  = var.department
    tier        = "NA"
  }
}

# Create a Virtual Network and associated subnets
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.resource_group}-vnet"
  location            = "${var.location}"
  address_space       = ["${var.vnetAddressSpace}"]
  resource_group_name = "${azurerm_resource_group.rg.name}"
  tags = {
    environment = var.environment
    project     = var.project
    department  = var.department
    tier        = "NA"
  }
}

resource "azurerm_subnet" "management" {
  name                 = "Management"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  resource_group_name  = azurerm_resource_group.rg.name
  address_prefix       = var.managementSubnet
}

resource "azurerm_subnet" "app" {
  name                 = "App"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  address_prefix       = "${var.appSubnet}"
}

# Create a Virtual Machine based on the Image

# Create public IP for Admin host
resource "azurerm_public_ip" "adminpublicip" {
    name                        = "${var.resource_group}-${var.vm1}-pip"
    location                    = azurerm_resource_group.rg.location
    resource_group_name         = azurerm_resource_group.rg.name
    sku                         = "Standard"
    allocation_method           = "Static"

    tags = {
      environment = var.environment
      project     = var.project
      department  = var.department
      tier        = "NA"
    }
}

# Create a network interface for VM
resource "azurerm_network_interface" "adminnic" {
  name                = "${var.resource_group}-${var.vm1}-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                           = "primary"
    subnet_id                      = azurerm_subnet.app.id
    private_ip_address_allocation  = "dynamic"
    public_ip_address_id           = "${azurerm_public_ip.adminpublicip.id}"
  }
  tags = {
    environment = var.environment
    project     = var.project
    department  = var.department
    tier        = "NA"
  }
}

# Create the Admin VM
resource "azurerm_virtual_machine" "adminvm" {
  provider                         = azurerm
  name                             = "${var.vm1}"
  location                         = azurerm_resource_group.rg.location
  resource_group_name              = azurerm_resource_group.rg.name
  network_interface_ids            = [azurerm_network_interface.adminnic.id]
  vm_size                          = "Standard_DS1_v2"
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
      id = "${data.azurerm_shared_image_version.sig1.id}"
  }

  storage_os_disk {
    name              = "${var.vm1}-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  os_profile_windows_config {
  }
  
  tags = {
    environment = var.environment
    project     = var.project
    department  = var.department
    tier        = "Admin"
  }
}

output "sigid" {
  value = "${data.azurerm_shared_image_version.sig1.id}"
}

output "adminpublicip" {
  value = azurerm_public_ip.adminpublicip.ip_address
}