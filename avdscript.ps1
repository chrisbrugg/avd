Set-SmbClientConfiguration -EncryptionCiphers "AES_256_GCM" -Confirm:$false

Add-LocalGroupMember `
    -Group "FSLogix Profile Exclude List" `
    -Member "$env:COMPUTERNAME\avdadmin"
