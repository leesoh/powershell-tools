function Test-Port {
    <#
    .SYNOPSIS
        Simple port scanner.

    .DESCRIPTION
        Pretty basic stuff. Stole most of the idea from
        http://www.powershelladmin.com/wiki/Check_for_open_TCP_ports_using_PowerShell.
        Returns an array of PSCustomObjects with the results

    .PARAMETER Port
        Target port(s)

    .PARAMETER Protocol
        TCP, UDP, or both

    .PARAMETER ComputerName
        Target computer(s)

    .EXAMPLE
        PS> Test-Port -Port 80,443 -ComputerName 192.168.45.1,192.168.45.104 -Protocol tcp,udp -Verbose
        VERBOSE: 192.168.45.1: tcp/80 is open
        VERBOSE: 192.168.45.1: udp/80 is closed or unavailable.
        VERBOSE: 192.168.45.1: tcp/443 is closed or unavailable.
        VERBOSE: 192.168.45.1: udp/443 is closed or unavailable.
        VERBOSE: 192.168.45.104: tcp/80 is closed or unavailable.
        VERBOSE: 192.168.45.104: udp/80 is closed or unavailable.
        VERBOSE: 192.168.45.104: tcp/443 is closed or unavailable.
        VERBOSE: 192.168.45.104: udp/443 is closed or unavailable.

        Computer       Protocol Port State
        --------       -------- ---- -----
        192.168.45.1   tcp        80 Open
        192.168.45.1   udp        80 Closed
        192.168.45.1   tcp       443 Closed
        192.168.45.1   udp       443 Closed
        192.168.45.104 tcp        80 Closed
        192.168.45.104 udp        80 Closed
        192.168.45.104 tcp       443 Closed
        192.168.45.104 udp       443 Closed
    #>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $True)]
        [ValidateRange(1,65535)]
        [int[]]
        $Port,

        [Parameter(Mandatory = $True)]
        [ValidateSet('TCP','UDP')]
        [string[]]
        $Protocol,

        [Parameter(Mandatory = $True)]
        [ValidateLength(1,15)]
        [string[]]
        $ComputerName
    )

    begin {
        $Results = @()
    }

    process {
        # Suppress errors when creating connection. May be better in a try/catch
        foreach ($C in $ComputerName) {
            foreach ($PortNumber in $Port) {
                foreach ($P in $Protocol) {
                    $SocketStatus = [pscustomobject]@{}
                    $SocketStatus | Add-Member -MemberType NoteProperty -Name 'Computer' -Value $C
                    $SocketStatus | Add-Member -MemberType NoteProperty -Name 'Protocol' -Value $P
                    $SocketStatus | Add-Member -MemberType NoteProperty -Name 'Port' -Value $PortNumber
                    $ErrorActionPreference = 'SilentlyContinue'
                    $Socket = New-Object "Net.Sockets.$($P + 'Client')"
                    $Socket.Connect($C, $PortNumber)

                    # Unsupress errors
                    $ErrorActionPreference = 'Continue'

                    if ($Socket.Connected) {
                        Write-Verbose "${C}: $P/$PortNumber is open"
                        $SocketStatus | Add-Member -MemberType NoteProperty -Name 'State' -Value 'Open'
                        $Socket.Close()
                        $Socket = $null
                    }

                    else {
                        Write-Verbose "${C}: $P/$PortNumber is closed or unavailable."
                        $SocketStatus | Add-Member -MemberType NoteProperty -Name 'State' -Value 'Closed'
                    }
                    $Results += $SocketStatus
                }

            }
        }
    }

    end {
        $Results
    }
}
