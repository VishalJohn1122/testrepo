variable "location" {
  default = "East US"
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
