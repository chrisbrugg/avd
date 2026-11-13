# SMB-Verschlüsselungs-Cipher setzen
try {
    Set-SmbClientConfiguration `
        -EncryptionCiphers "AES_256_GCM" `
        -Confirm:$false `
        -ErrorAction Stop
}
catch {
    Write-Warning "SMB-Cipher konnte nicht gesetzt werden: $($_.Exception.Message)"
}
