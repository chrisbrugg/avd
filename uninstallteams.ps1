# Teams für neue Benutzerprofile aus dem Image entfernen
Get-AppxProvisionedPackage -Online |
    Where-Object { $_.DisplayName -in 'MSTeams', 'MicrosoftTeams' } |
    ForEach-Object {
        Remove-AppxProvisionedPackage -Online -PackageName $_.PackageName -ErrorAction Stop
    }

# Teams für bereits vorhandene Benutzerprofile entfernen
Get-AppxPackage -AllUsers |
    Where-Object { $_.Name -in 'MSTeams', 'MicrosoftTeams' } |
    ForEach-Object {
        Remove-AppxPackage -AllUsers -Package $_.PackageFullName -ErrorAction Stop
    }
