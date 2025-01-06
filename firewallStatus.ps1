# Check the status of the Windows Firewall for each profile
try {
    $firewallProfiles = Get-NetFirewallProfile

    # Check if specific profiles are enabled
    $privateFirewallEnabled = ($firewallProfiles | Where-Object { $_.Name -eq "Private" -and $_.Enabled -eq $true }).Count -gt 0
    $publicFirewallEnabled = ($firewallProfiles | Where-Object { $_.Name -eq "Public" -and $_.Enabled -eq $true }).Count -gt 0
    $domainFirewallEnabled = ($firewallProfiles | Where-Object { $_.Name -eq "Domain" -and $_.Enabled -eq $true }).Count -gt 0

    # Aggregate status considering only Private and Public profiles
    $firewallStatus = $privateFirewallEnabled -or $publicFirewallEnabled

    # Debugging: Output the statuses
    Write-Output "Private Firewall Enabled: $privateFirewallEnabled"
    Write-Output "Public Firewall Enabled: $publicFirewallEnabled"
    Write-Output "Domain Firewall Enabled: $domainFirewallEnabled"
    Write-Output "Overall Firewall Status (Private/Public only): $firewallStatus"
} catch {
    Write-Output "Error checking firewall status: $_"
    exit 1
}

# Determine the output for the custom field
$firewallStatusResult = if ($firewallStatus) { "TRUE" } else { "FALSE" }

# NinjaRMM CLI Path
$ninjaCliPath = "C:\ProgramData\NinjaRMMAgent\ninjarmm-cli.exe"

# Debugging: Show the command being executed
Write-Output "Running command: $ninjaCliPath set firewallStatus $firewallStatusResult"

# Run the CLI command and capture output and exit code
$ninjaCommand = & $ninjaCliPath set "firewallStatus" "$firewallStatusResult" 2>&1
$exitCode = $LASTEXITCODE

# Output the response and exit code
Write-Output "CLI Response: $ninjaCommand"
Write-Output "Exit Code: $exitCode"

# Check for success or failure
if ($exitCode -eq 0) {
    Write-Output "Custom field 'firewallStatus' updated successfully with value '$firewallStatusResult'."
} else {
    Write-Output "Failed to update custom field 'firewallStatus'. Exit code: $exitCode"
}
