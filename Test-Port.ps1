<#
.SYNOPSIS
    Checks for open port on target(s)

.DESCRIPTION
    Pretty basic stuff. Stole most of the idea from
    http://www.powershelladmin.com/wiki/Check_for_open_TCP_ports_using_PowerShell.
    Will return $True if open, $False otherwise

.PARAMETER Port
    One or more ports

.PARAMETER Protocol
    Must be either TCP or UDP

.PARAMETER Targets
    One or more targets

.EXAMPLE
    Test-Port -Port 3389 -Protocol TCP -Targets 127.0.0.1 -Verbose

.NOTES
    Author: Liam Somerville
    Date: 2016-02-28
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $True)]
    [ValidateRange(1,65535)]
    [int]$Port,

    [Parameter(Mandatory = $True)]
    [ValidateSet('TCP','UDP')]
    [string]$Protocol,

    [Parameter(Mandatory = $True)]
    [ValidateLength(1,15)]
    [string]$Targets
)

Begin {
    $Status = ''
}

Process {
    foreach ($Target in $Targets) {
        # Suppress errors when creating connection. May be better in a try/catch
        $ErrorActionPreference = 'SilentlyContinue'
        $Socket = New-Object "Net.Sockets.$($Protocol + 'Client')"
        $Socket.Connect($Target, $Port)

        # Unsupress errors
        $ErrorActionPreference = 'Continue'

        if ($Socket.Connected) {
            Write-Verbose "${Target}: $Protocol/$Port is open"
            $Status = $True
            $Socket.Close()
            $Socket = $null
        }

        else {
            Write-Verbose "${Target}: $Protocol/$Port is closed or unavailable."
            $Status = $False
        }
    }
}

End {
    $Status
}