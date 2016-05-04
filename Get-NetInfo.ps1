function Get-NetInfo {
    <#
        .SYNOPSIS
        Gathers network info using WMI

        .DESCRIPTION
        Gathers IP Addresses, Subnet Mask, and Default Gateway for each adapter present on the target and returns
        an array.

        .PARAMETER $Target
        The target of the query.

        .EXAMPLE
        Get-NetInfo -Target "192.168.1.1"

        .NOTES
        Version: 1.0
        Author: Liam Somerville
        Date: 2015-10-21
    #>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $True,
                   ValueFromPipeLine = $True)]
        $Target,

        $Credentials
    )

    begin {
        Write-Verbose "[*] Beginning Get-NetInfo for $Target..."
        $Results = @()
        $Namespace = "root\cimv2"
    }

    process {
        foreach ($T in $Target) {

            Write-Verbose "[*] Gathering network information..."
            $WMINetInfo = Get-WmiObject -Class Win32_NetworkAdapterConfiguration -ComputerName $Target -Namespace $Namespace -Credential $Credentials
            $WMIEthInfo = Get-WmiObject -Class Win32_NetworkAdapter -ComputerName $Target -Namespace $Namespace -Credential $Credentials

            if ($WMINetInfo) {
                Write-Verbose '[+] $WMINetInfo is present...'
                foreach ($Adapter in $WMINetInfo) {
                    $AdapterName = "Adapter $($Adapter.Index)"

                    # Get the index of the current adapter in the list of adapters. This allows us to correlate a MAC.
                    $AdapterIndex = [array]::IndexOf($WMINetInfo, $Adapter)

                    # We only care about this info if there is an IP address
                    if ($Adapter.IPAddress){
                        Write-Verbose "[*] Creating information from $AdapterName..."
                        $AdapterName = @{}
                        $AdapterName['IPAddress'] = $Adapter.IPAddress[0]
                        $AdapterName['SubnetMask'] = $Adapter.IPSubnet[0]
                        $AdapterName['MACAddress'] = $WMIEthInfo[$AdapterIndex].MACAddress

                        # If there's also default gateway, record it
                        if ($Adapter.DefaultIPGateway) {
                            $AdapterName['DefaultGateway'] = $Adapter.DefaultIPGateway[0]
                        }

                        # If there's no gateway, just put N/A
                        elseif (!($Adapter.DefaultIPGateway)) {
                            $AdapterName['DefaultGateway'] = 'N/A'
                        }

                        else {
                            Write-Verbose "[-] No Default Gateway found for $AdapterName"
                        }
                        $Results += $AdapterName
                    }
                }
            }
            else {
                Write-Error '[-] Network Information unavailable!'
                $Results = 'Unavailable'
            }
        }
    }
    end {
        Write-Verbose "[*] Processing network info complete, returning results..."
        $Results
    }
}