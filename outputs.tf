output "public_ip_address" {
  value = azurerm_public_ip.tst-public_ip.ip_address
}

output "storage_account_name" {
  value = azurerm_storage_account.testsanova13.name
}

output "key_vault_uri" {
  value = azurerm_key_vault.testkvnova130922.vault_uri
}


