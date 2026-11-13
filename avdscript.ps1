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

# avdadmin in die FSLogix-Exclude-Gruppe aufnehmen, falls nötig
try {
    $GroupName = "FSLogix Profile Exclude List"
    $UserName  = "$env:COMPUTERNAME\avdadmin"

    $Group = Get-LocalGroup -Name $GroupName -ErrorAction Stop
    $IsMember = Get-LocalGroupMember -Group $GroupName -ErrorAction Stop |
        Where-Object { $_.Name -ieq $UserName }

    if (-not $IsMember) {
        Add-LocalGroupMember -Group $GroupName -Member $UserName -ErrorAction Stop
        Write-Host "Benutzer hinzugefügt: $UserName -> $GroupName"
    }
    else {
        Write-Host "Benutzer ist bereits Mitglied: $UserName -> $GroupName"
    }
}
catch {
    Write-Warning "FSLogix-Gruppe oder Mitgliedschaft konnte nicht verarbeitet werden: $($_.Exception.Message)"
}

# Apps, die aus bestehenden Benutzerprofilen und dem Image entfernt werden sollen
$AppNames = @(
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
    "TikTok.TikTok",
    "MSTeams"
) | Select-Object -Unique

# Einmal Bestandslisten abrufen; Pakete danach einzeln entfernen
try {
    $InstalledPackages = @(Get-AppxPackage -AllUsers -ErrorAction Stop)
}
catch {
    $InstalledPackages = @()
    Write-Warning "Installierte Appx-Pakete konnten nicht aufgelistet werden: $($_.Exception.Message)"
}

try {
    $ProvisionedPackages = @(Get-AppxProvisionedPackage -Online -ErrorAction Stop)
}
catch {
    $ProvisionedPackages = @()
    Write-Warning "Bereitgestellte Appx-Pakete konnten nicht aufgelistet werden: $($_.Exception.Message)"
}

foreach ($AppName in $AppNames) {
    $InstalledMatches = @($InstalledPackages | Where-Object { $_.Name -eq $AppName })

    foreach ($Package in $InstalledMatches) {
        try {
            Write-Host "Entferne installiertes Paket: $($Package.PackageFullName)"
            Remove-AppxPackage `
                -Package $Package.PackageFullName `
                -AllUsers `
                -ErrorAction Stop
        }
        catch {
            Write-Warning "Paket konnte nicht entfernt werden ($($Package.PackageFullName)): $($_.Exception.Message)"
        }
    }

    $ProvisionedMatches = @($ProvisionedPackages | Where-Object { $_.DisplayName -eq $AppName })

    foreach ($Package in $ProvisionedMatches) {
        try {
            Write-Host "Entferne bereitgestelltes Paket: $($Package.PackageName)"
            Remove-AppxProvisionedPackage `
                -Online `
                -PackageName $Package.PackageName `
                -ErrorAction Stop | Out-Null
        }
        catch {
            Write-Warning "Bereitgestelltes Paket konnte nicht entfernt werden ($($Package.PackageName)): $($_.Exception.Message)"
        }
    }

    if (($InstalledMatches.Count -eq 0) -and ($ProvisionedMatches.Count -eq 0)) {
        Write-Host "Nicht vorhanden, übersprungen: $AppName"
    }
}
