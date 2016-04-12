<#
.SYNOPSIS
    Checks for open port on target(s)

.DESCRIPTION
    Pretty basic stuff. Stole most of the idea from
    http://www.powershelladmin.com/wiki/Check_for_open_TCP_ports_using_PowerShell.
    Will return $True if open, $False otherwise

.PARAMETER Port
    Target port

.PARAMETER Protocol
    Must be either TCP or UDP

.PARAMETER ComputerName
    Target computer

.EXAMPLE
    Test-Port -Port 3389 -Protocol TCP -ComputerName 127.0.0.1 -Verbose

.NOTES
    Author: Liam Somerville
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $True)]
    [ValidateRange(1,65535)]
    [int]
    $Port,

    [Parameter(Mandatory = $True)]
    [ValidateSet('TCP','UDP')]
    [string]
    $Protocol,

    [Parameter(Mandatory = $True)]
    [ValidateLength(1,15)]
    [string]
    $ComputerName
)

begin {
    $Status = ''
}

process {
    # Suppress errors when creating connection. May be better in a try/catch
    $ErrorActionPreference = 'SilentlyContinue'
    $Socket = New-Object "Net.Sockets.$($Protocol + 'Client')"
    $Socket.Connect($ComputerName, $Port)

    # Unsupress errors
    $ErrorActionPreference = 'Continue'

    if ($Socket.Connected) {
        Write-Verbose "${ComputerName}: $Protocol/$Port is open"
        $Status = $True
        $Socket.Close()
        $Socket = $null
    }

    else {
        Write-Verbose "${ComputerName}: $Protocol/$Port is closed or unavailable."
        $Status = $False
    }
}

end {
    $Status
}
