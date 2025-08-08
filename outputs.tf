output "public_ip_address" {
  value = azurerm_public_ip.Tst-public_ip.ip_address
}

output "storage_account_name" {
  value = azurerm_storage_account.TestSA.name
}

output "key_vault_uri" {
  value = azurerm_key_vault.TestKV.vault_uri
}

