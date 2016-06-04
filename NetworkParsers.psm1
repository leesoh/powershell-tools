function Get-Info ($Line) {
    $AdapterSetting = @{}
    # Split on this so we don't accidentally grab IPv6 address
    $LineArray = $Line -split ' : '
    $Setting = $LineArray[0].Replace(' ', '')
    $Setting = $Setting.Replace('.', '')
    $AdapterSetting['Setting'] = $Setting
    $AdapterSetting['Value'] = $LineArray[1]
    $AdapterSetting
}

function Import-IPConfig {
    <#
    .SYNOPSIS
    Parses the output of ipconfig or ipconfig /all and returns an object.

    .DESCRIPTION
    Gathers information for each adapter present on the target and returns and array of objects.

    .PARAMETER Path
    Path to file[s]

    .PARAMETER Extension
    Extension for output files. Defaults to '*.txt'

    .PARAMETER Property
    Regex for target properties of each adapter. Defaults to 'Media State|Address|Mask|Gateway|Description'

    .PARAMETER ExcludedAdapters
    Regex for adapters to exclude. Defaults to 'Tunnel'

    .EXAMPLE
    PS> .\Import-IPConfig.ps1 -Path C:\Path\To\Files -Property 'address|subnet'
    #>

    [CmdletBinding()]

    param (
        [Parameter(Mandatory = $True,
                   ValueFromPipeLine = $True)]
        [ValidateScript({Test-Path -Path $_})]
        [string]
        $Path,
        [string]
        $Extension = '*.txt',
        [string]
        $Property = [regex]'Media State|Address|Mask|Gateway|Description',
        [string]
        $ExcludedAdapters = [regex]'Tunnel'
    )

    begin {
        $Results = @()
        $AdapterRegex = [regex]'adapter.*:'
        $ConfigFiles = Get-ChildItem -Path $Path -Recurse -File -Include $Extension
    }

    process {
        foreach ($File in $ConfigFiles) {
            try {
                Select-String -Path $File -Pattern 'Windows IP Configuration'
            }
            catch {
                Write-Verbose -Message "No IP information found in $C"
                Break
            }
            $Adapter = [pscustomobject]@{}
            $Hostname = ((Select-String -Path $File -Pattern 'Host Name').Line -split ' : ')[1]
            $DNSSuffix = ((Select-String -Path $File -Pattern 'Primary Dns Suffix').Line -split ' : ')[1]

            # Get everything but the blank lines
            $Contents = Get-Content -Path $File | Where-Object {$_ -ne ''}

            # Will need to parse the Windows IP Configuration
            foreach ($Line in $Contents) {
                # If we should be skipping this adapter, set the name to 'skip' so subsequent lines are ignored
                if ($Line -match $ExcludedAdapters) {
                    $AdapterName = 'skip'
                    Continue
                }

                # If the line matches 'adapter' and we haven't yet seen one, create a new object to hold it, and we're not
                # skipping this adapter, assign this adapter as the new adapter name.
                elseif (($Line -match $AdapterRegex) -and (!($AdapterName)) -and ($AdapterName -ne 'skip')) {
                    $Adapter = [pscustomobject]@{}
                    $AdapterName = $Line.Replace(':', '')
                    Write-Verbose -Message "Adapter found: $AdapterName"
                    $Adapter | Add-Member -Name Hostname -Value $Hostname -MemberType NoteProperty
                    $Adapter | Add-Member -Name PrimaryDnsSuffix -Value $DNSSuffix -MemberType NoteProperty
                    $Adapter | Add-Member -Name 'AdapterName' -Value $AdapterName -MemberType NoteProperty
                }
                # If the line matches 'adapter' but hasn't been caught yet, we have reached the next adapter and need to
                # start over.
                elseif ($Line -match $AdapterRegex) {
                    $Results += $Adapter
                    $Adapter = [pscustomobject]@{}
                    $AdapterName = $Line.Replace(':', '')
                    Write-Verbose -Message "Adapter found: $AdapterName"
                    $Adapter | Add-Member -Name Hostname -Value $Hostname -MemberType NoteProperty
                    $Adapter | Add-Member -Name PrimaryDnsSuffix -Value $DNSSuffix -MemberType NoteProperty
                    $Adapter | Add-Member -Name 'AdapterName' -Value $AdapterName -MemberType NoteProperty
                }
                # Otherwise we're just adding more properties for the current adapter. Carry on.
                elseif ($AdapterName -and ($Line -match $Property) -and ($AdapterName -ne 'skip')) {
                    $AdapterSetting = Get-Info $Line
                    $Adapter | Add-Member -Name $AdapterSetting.Setting -Value $AdapterSetting.Value -MemberType NoteProperty
                }
                else {
                    Write-Verbose -Message "No adapter found yet, skipping."
                }
            }
            # Add the last adapter to results
            $Results += $Adapter
        }
    }
    end {
        $Results
    }
}

function Import-Netstat {
    <#
    .SYNOPSIS
    Parses Netstat

    .DESCRIPTION
    Takes saved Netstat output (supports any combination of -a, -n, -o), parses, and returns as an object.

    .PARAMETER Path
    Path to file(s)

    .EXAMPLE
    Import-Netstat.ps1 -Path C:\Path\To\Files
    #>

    [CmdletBinding()]

    Param (
        [Parameter(Mandatory = $True,
                ValueFromPipeline = $True)]
        [ValidateScript({Test-Path -Path $_})]
        [string]
        $Path
    )

    begin {
        $Results = @()
        $Files = Get-ChildItem -Path $Path -Recurse -File
    }

    process {
        foreach ($File in $Files) {
            $FileData = Get-Content -Path $File
            $Header = $FileData[3]
            $Header = $Header.Trim()

            # Split on two or more spaces to ensure we don't split property names containing spaces
            $HeaderArray = $Header -split '  +'

            foreach ($Connection in $FileData[4..$FileData.Length]) {
                $ConnObject = [PSCustomObject] @{}
                $Connection = $Connection.Trim()
                $ConnectionArray = $Connection -split ' +'

                # Links the header array with the appropriate connection array. Also remove spaces, because we like that.
                for ($i = 0; $i -lt $HeaderArray.Length; $i++) {
                    Add-Member -InputObject $ConnObject -MemberType NoteProperty -Name $($HeaderArray[$i].Replace(' ', '')) -Value $ConnectionArray[$i]
                }
                $Results += $ConnObject
            }
        }
    }

    end {
        $Results
    }
}

Export-ModuleMember -Function Import-IPConfig
Export-ModuleMember -Function Import-Netstat
