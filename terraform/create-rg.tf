# Configure the Azure Provider
provider "azurerm" {
  # whilst the `version` attribute is optional, we recommend pinning to a given version of the Provider
  version = "=1.43.0"
}

##########################################################################################################
#                                              VARIABLES                                                 #
##########################################################################################################

# Resource group name
variable "rg_name" {
  type        = string
  description = "Enter the name of the resource group to create"
}

# Location
variable "location" {
  type        = string
  description = "Enter your location (e.g. eastus, westus2, etc.) "
}

# VNet name
variable "vnet_name" {
   type	       = string
   description = "Enter the VNet name to create " 
}

# VNet address space
variable "vnet_addr_space" {
   type	       = string
   description = "Enter the VNet address space CIDR (ex 10.10.0.0/16) " 
}

# Subnet name 
variable "subnet_name" {
    type        = string
    description = "Enter the WAF subnet name to create"
}

# Subnet addr prefix
variable "subnet_addr_prefix" {
    type        = string
    description = "Enter the WAF subnet addr prefix CIDR (ex  10.10.0.0/24)"
}

# WAF temp PIPs
variable "waf1_pip_name" {
    type        = string
    description = "Enter the WAF1 temp pub IP name "
}

variable "waf2_pip_name" {
    type        = string
    description = "Enter the WAF2 temp pub IP name "
}

# WAF Standard LB Pub IP
variable "waf_elb_pip_name" {
    type        = string
    description = "Enter the ELB pub IP name "
}

# NSG for WAF subnet
variable "waf_subnet_nsg_name" {
    type        = string
    description = "Enter the WAF subnet NSG name "
}

# NICs for WAFs
variable "waf1_nic_name" {
    type        = string
    description = "Enter the name for WAF NIC 1 "
}

variable "waf2_nic_name" {
    type        = string
    description = "Enter the name for WAF NIC 2 "
}

# VM names for WAFs
variable "waf1_vm_name" {
    type        = string
    description = "Enter the VM name for WAF 1 "
}

variable "waf2_vm_name" {
    type        = string
    description = "Enter the VM name for WAF 2 "
}

# WAF sku, i.e. byol or hourly
variable "waf_sku" {
    type        = string
    description = "Enter the WAF sku ('byol' or 'hourly') "
}

# WAF VM size, i.e. DS1_v2, etc.
variable "waf_vm_size" {
    type        = string
    description = "Enter the WAF VM size (DS1_v2, DS2_v2, etc.) "
}

# Admin password
variable "admin_password" {
    type        = string
    description = "Enter the admin password"
}

# WAF license acceptance
variable "waf_signature" {
    type        = string
    description = "Enter the WAF signature "
}

variable "waf_email" {
    type        = string
    description = "Enter the WAF email  "
}

variable "waf_organization" {
    type        = string
    description = "Enter the WAF organization "
}


##########################################################################################################
#                                              RESOURCES                                                 #
##########################################################################################################

# Create the resource group
resource "azurerm_resource_group" "rg-lab" {
    name     = var.rg_name
    location = var.location

    tags = {
        owner = "mcollins"
    }
}

# Create VNet
resource "azurerm_virtual_network" "vnet-lab" {
    name                = var.vnet_name
    location            = var.location
    address_space       = [var.vnet_addr_space]
    resource_group_name = azurerm_resource_group.rg-lab.name
}

# Create Subnet
resource "azurerm_subnet" "waf-subnet-lab" {
    name                 = var.vnet_name
    resource_group_name  = azurerm_resource_group.rg-lab.name
    virtual_network_name = azurerm_virtual_network.vnet-lab.name
    address_prefix       = var.subnet_addr_prefix
}

# Create WAF PIPs
resource "azurerm_public_ip" "waf1-pip" {
    name                         = var.waf1_pip_name
    location                     = var.location
    resource_group_name          = azurerm_resource_group.rg-lab.name
    allocation_method            = "Static"
}

resource "azurerm_public_ip" "waf2-pip" {
    name                         = var.waf2_pip_name
    location                     = var.location
    resource_group_name          = azurerm_resource_group.rg-lab.name
    allocation_method            = "Static"
}

# Create WAF ELB standard PIP
resource "azurerm_public_ip" "waf-elb-pip" {
    name                         = var.waf_elb_pip_name
    location                     = var.location
    resource_group_name          = azurerm_resource_group.rg-lab.name
    allocation_method            = "Static"
    sku                          = "Standard"
}

# Create WAF subnet NSG
resource "azurerm_network_security_group" "waf-subnet-nsg" {
    name                = var.waf_subnet_nsg_name
    location            = var.location
    resource_group_name = azurerm_resource_group.rg-lab.name

    security_rule {
        name                       = "SSH"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "HTTP80"
        priority                   = 110
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "HTTPS443"
        priority                   = 120
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "HTTP8080"
        priority                   = 130
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "8080"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "WAF-Admin-8000"
        priority                   = 140
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "8000"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "WAF-Admin-8443"
        priority                   = 150
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "8443"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
}

# Associate subnet with NSG
resource "azurerm_subnet_network_security_group_association" "waf-nsg-subnet-assoc" {
    subnet_id                 = azurerm_subnet.waf-subnet-lab.id
    network_security_group_id = azurerm_network_security_group.waf-subnet-nsg.id
}

# Create NICs for WAFs
resource "azurerm_network_interface" "nic-waf1" {
    name                      = var.waf1_nic_name
    location                  = var.location
    resource_group_name       = azurerm_resource_group.rg-lab.name

    ip_configuration {
        name                          = "IPConfig1"
        subnet_id                     = azurerm_subnet.waf-subnet-lab.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.waf1-pip.id
    }
}

# Create network interface
resource "azurerm_network_interface" "nic-waf2" {
    name                      = var.waf2_nic_name
    location                  = var.location
    resource_group_name       = azurerm_resource_group.rg-lab.name

    ip_configuration {
        name                          = "IPConfig1"
        subnet_id                     = azurerm_subnet.waf-subnet-lab.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.waf2-pip.id
    }
}

# Generate random text for a unique storage account name
resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = azurerm_resource_group.rg-lab.name
    }
    
    byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "sa_boot_diag" {
    name                        = "diag${random_id.randomId.hex}"
    resource_group_name         = azurerm_resource_group.rg-lab.name
    location                    = var.location
    account_tier                = "Standard"
    account_replication_type    = "LRS"
}

#create WAF1
resource "azurerm_virtual_machine" "vm_waf1" {
    name                  = var.waf1_vm_name
    location              = var.location
    plan {
      publisher          = "barracudanetworks"
      name               = var.waf_sku
      product            = "waf"
    }
    
    resource_group_name   = azurerm_resource_group.rg-lab.name
    network_interface_ids = [azurerm_network_interface.nic-waf1.id]
    vm_size               = var.waf_vm_size
	
    delete_os_disk_on_termination = true
    delete_data_disks_on_termination = true

    storage_os_disk {
        name              = "osdisk_waf1"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Premium_LRS"
    }

    storage_image_reference {
        publisher = "barracudanetworks"
        offer     = "waf"
        sku       = var.waf_sku
        version   = "latest"
    }
	
    os_profile {
        computer_name  = var.waf1_vm_name
        admin_username = "not_used"
        admin_password = var.admin_password
        custom_data = "{\"signature\": \"var.waf_signature\", \"email\": \"var.waf_email\", \"organization\": \"var.waf_organization\"}"
    }

    os_profile_linux_config {
        disable_password_authentication = false
    }
}

#create WAF2
resource "azurerm_virtual_machine" "vm_waf2" {
    name                  = var.waf2_vm_name
    location              = var.location
    plan {
      publisher          = "barracudanetworks"
      name               = var.waf_sku
      product            = "waf"
    }
    
    resource_group_name   = azurerm_resource_group.rg-lab.name
    network_interface_ids = [azurerm_network_interface.nic-waf2.id]
    vm_size               = var.waf_vm_size
	
    delete_os_disk_on_termination = true
    delete_data_disks_on_termination = true

    storage_os_disk {
        name              = "osdisk_waf2"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Premium_LRS"
    }

    storage_image_reference {
        publisher = "barracudanetworks"
        offer     = "waf"
        sku       = var.waf_sku
        version   = "latest"
    }
	
    os_profile {
        computer_name  = var.waf1_vm_name
        admin_username = "not_used"
        admin_password = var.admin_password
        custom_data = "{\"signature\": \"var.waf_signature\", \"email\": \"var.waf_email\", \"organization\": \"var.waf_organization\"}"
    }

    os_profile_linux_config {
        disable_password_authentication = false
    }
}

output "WAF1_VM_PIP" {
    description = "WAF 1 temp public IP"
    value       = azurerm_public_ip.waf1-pip.ip_address
}

output "WAF2_VM_PIP" {
    description = "WAF 2 temp public IP"
    value       = azurerm_public_ip.waf2-pip.ip_address
}

output "WAF_LB_PIP" {
    description = "WAF ELB public IP"
    value       = azurerm_public_ip.waf-elb-pip.ip_address
}
