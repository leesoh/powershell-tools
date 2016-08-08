function Get-NetInfo {
    <#
        .SYNOPSIS
        Gathers network info using WMI

        .DESCRIPTION
        Gathers IP Addresses, Subnet Mask, and Default Gateway for each adapter present on the target and returns
        an array.

        .PARAMETER ComputerName
        Target computer(s)

        .EXAMPLE
    #>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $True,
                   ValueFromPipeLine = $True)]
        [string[]]
        $ComputerName
    )

    begin {
        $Results = @()
        $Namespace = "root\cimv2"
        $Credentials = Get-Credential
    }

    process {
        foreach ($C in $ComputerName) {
            Write-Verbose "[*] Beginning Get-NetInfo for $C..."
            try {
                $WMINetInfo = Get-WmiObject -Class Win32_NetworkAdapterConfiguration -ComputerName $C -Namespace $Namespace -Credential $Credentials -ErrorAction Stop
                $WMIEthInfo = Get-WmiObject -Class Win32_NetworkAdapter -ComputerName $C -Namespace $Namespace -Credential $Credentials -ErrorAction Stop
                $WMISysInfo = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $C -Namespace $Namespace -Credential $Credentials -ErrorAction Stop
            }

            catch {
                Write-Verbose -Message "[-] WMI information not available on $C"
            }

            if ($WMINetInfo) {
                Write-Verbose '[+] $WMINetInfo is present...'
                foreach ($Adapter in $WMINetInfo) {
                    $AdapterName = "Adapter $($Adapter.Index)"
                    Write-Verbose -Message "[*] Now processing $AdapterName"

                    # Get the index of the current adapter in the list of adapters. This allows us to correlate a MAC.
                    $AdapterIndex = [array]::IndexOf($WMINetInfo, $Adapter)

                    # We only care about this info if there is an IP address
                    if ($Adapter.IPAddress){
                        Write-Verbose -Message "[+] IP is present on $AdapterName"
                        $AdapterProps = [ordered]@{
                            'Computer'       = $WMISysInfo.Name
                            'Adapter'        = $AdapterName
                            'IPAddress'      = $Adapter.IPAddress[0]
                            'MAC'            = $WMIEthInfo[$AdapterIndex].MACAddress
                            'Subnet'         = $Adapter.IPSubnet[0]
                            'DefaultGateway' = 'N/A'
                        }

                        # If there's also default gateway, record it
                        if ($Adapter.DefaultIPGateway) {
                            Write-Verbose -Message "[+] Default Gateway found on $AdapterName"
                            $AdapterProps['DefaultGateway'] = $Adapter.DefaultIPGateway[0]
                        }

                        $AdapterInfo = New-Object -TypeName PSCustomObject -Property $AdapterProps
                        $Results += $AdapterInfo
                    }
                }
            }
            else {
                Write-Verbose -Message "[-] Network Information unavailable for $C"
            }
        }
    }
    end {
        Write-Verbose "[*] Processing network info complete, returning results..."
        $Results
    }
}
