variable "location" {
  default = "East US"
}

variable "subscription_id" {
  default = "33ef9b7d-a911-4f94-b5af-ece5c659895e"
}

variable "tenant_id" {
  default = "673186d0-7ebe-472d-b2f0-6bd1911b9b12"
}

variable "resource_group_name" {
  default = "TestRG"
}

variable "storage_account_name" {
  default = "TestSA"
}

variable "key_vault_name" {
  default = "TestKV"
}

variable "vm_size" {
  default = "Standard_B1s"
}

variable "admin_username" {
  default = "TestUser"
}

variable "admin_password" {
  default = "Password@1234" # Use a secure password in production
}

