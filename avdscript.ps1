Set-SmbClientConfiguration -EncryptionCiphers "AES_256_GCM" -Confirm:$false

Add-LocalGroupMember `
    -Group "FSLogix Profile Exclude List" `
    -Member "$env:COMPUTERNAME\avdadmin"

$AppList = @(
    "Microsoft.BingNews",
    "Microsoft.BingWeather",
    "Microsoft.GetHelp",
    "Microsoft.Getstarted",
    "Microsoft.MicrosoftOfficeHub",
    "Microsoft.MicrosoftSolitaireCollection",
    "Microsoft.MixedReality.Portal",
    "Microsoft.OneConnect",
    "Microsoft.People",
    "Microsoft.SkypeApp",
    "Microsoft.Todos",
    "Microsoft.WindowsAlarms",
    "Microsoft.WindowsFeedbackHub",
    "Microsoft.WindowsMaps",
    "Microsoft.WindowsSoundRecorder",
    "Microsoft.YourPhone",
    "Microsoft.ZuneMusic",
    "Microsoft.ZuneVideo",
    "Microsoft.Clipchamp",
    "Microsoft.WindowsTips",
    "Microsoft.WindowsCamera",
    "Microsoft.Windows.Photos",
    "Microsoft.Xbox.TCUI",
    "Microsoft.XboxGameOverlay",
    "Microsoft.XboxGamingOverlay",
    "Microsoft.XboxIdentityProvider",
    "Microsoft.XboxSpeechToTextOverlay",
    "Microsoft.XboxApp",
    "SpotifyAB.SpotifyMusic",
    "Disney.37853FC22B2CE",
    "Clipchamp.Clipchamp",
    "TikTok.TikTok"
)

ForEach ($App in $AppList) {
    $AppFullName = (Get-AppxPackage -AllUsers | Where-Object {$_.Name -eq $App}).PackageFullName
    $ProAppFullName = (Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -eq $App}).PackageName
    
    if ($AppFullName) {
        Write-Host "Removing package: $App"
        Remove-AppxPackage -Package $AppFullName -AllUsers
    } else {
        Write-Host "Unable to find package: $App"
    }
    
    if ($ProAppFullName) {
        Write-Host "Removing provisioned package: $ProAppFullName"
        Remove-AppxProvisionedPackage -Online -PackageName $ProAppFullName
    } else {
        Write-Host "Unable to find provisioned package: $App"
    }
}
