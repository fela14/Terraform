Terraform Azure VM Deployment

This Terraform configuration automates the provisioning of a Linux Virtual Machine in Azure. It includes networking setup, security rules, public IP assignment, and SSH configuration for remote access. The project is designed to be modular and supports both Linux and Windows host environments for local SSH configuration updates.

Table of Contents

Prerequisites

Project Overview

Resources Created

How Provisioning Works

Using the Outputs

Customizations

Prerequisites

Terraform v1.3+

Azure CLI configured and logged in

SSH key pair (~/.ssh/id_rsa and ~/.ssh/id_rsa.pub)

Optional: cloud-init script customdata.tpl for bootstrapping software like Docker

windows-ssh-script.tpl and linux-ssh-script.tpl templates for updating local SSH config

Project Overview

This Terraform project deploys a Linux Virtual Machine (ntc_vm) in Azure with the following workflow:

Creates a resource group in West Europe.

Creates a Virtual Network (VNet) with a subnet.

Sets up a Network Security Group (NSG) with rules for SSH (port 22) and HTTP (port 80).

Allocates a dynamic public IP and associates it with a network interface (NIC).

Deploys a Linux VM using Ubuntu 20.04 LTS.

Uses cloud-init via custom_data to install software like Docker automatically.

Uses a local-exec provisioner to update your local SSH configuration so you can connect to the VM easily.

Exposes the VM's public IP as an output.

Resources Created
Resource	Description
azurerm_resource_group	Groups all Azure resources under a single logical container.
azurerm_virtual_network	Defines the VNet for your VM.
azurerm_subnet	Subnet within the VNet for IP allocation.
azurerm_network_security_group	Controls inbound traffic; allows SSH and HTTP.
azurerm_subnet_network_security_group_association	Links the NSG to the subnet.
azurerm_public_ip	Assigns a public IP to the VM for internet access.
azurerm_network_interface	Connects the VM to the subnet and public IP.
azurerm_linux_virtual_machine	The VM itself, including SSH key authentication.
data.azurerm_public_ip	Fetches the public IP assigned to the VM after deployment.
output.public_ip_address	Displays VM name and public IP after terraform apply.
How Provisioning Works
VM Deployment

The VM uses the Ubuntu 20.04 LTS image.

Admin username: azureuser.

SSH key authentication ensures secure login.

custom_data allows automatic bootstrapping (e.g., install Docker).

Local SSH Configuration

The local-exec provisioner runs a template script to update your local ~/.ssh/config.

Template variables:

hostname – alias to access the VM (ntc_vm by default).

public_ip – the dynamic public IP of the VM.

user – admin username (azureuser).

identityFile – path to your private SSH key.

Interpreter switches based on the host OS:

Linux/macOS: /bin/bash -c

Windows: PowerShell -Command

Example snippet for Linux:

cat << EOF >> ~/.ssh/config
Host ntc_vm
    HostName 20.50.60.70
    User azureuser
    IdentityFile ~/.ssh/id_rsa
    StrictHostKeyChecking no
EOF

Using the Outputs

After running:

terraform init
terraform plan
terraform apply


Terraform will output something like:

VM Name: ntc_vm, Public IP: 20.50.60.70


You can then SSH into the VM with:

ssh ntc_vm

Customizations

Host OS Variable – Configure which SSH template to use in terraform.tfvars:

host_os = "windows"  # or "linux"


VM Size – Change the size attribute in azurerm_linux_virtual_machine.

VNet/Subnet – Adjust address_space and address_prefixes as needed.

NSG Rules – Add or remove inbound ports depending on your application.

Cloud-init – Modify customdata.tpl to install additional software.