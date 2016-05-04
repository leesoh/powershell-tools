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
