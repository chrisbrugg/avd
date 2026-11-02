Set-SmbClientConfiguration -EncryptionCiphers "AES_256_GCM" -Confirm:$false

$admins = Get-LocalGroup -SID 'S-1-5-32-544'
$exclude = Get-LocalGroup -Name 'FSLogix Profile Exclude List'

Add-LocalGroupMember -Group $exclude.Name -Member $admins.Name
