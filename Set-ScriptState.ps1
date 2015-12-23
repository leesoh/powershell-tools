<#
.SYNOPSIS
    Allows script state persistence across instances.

.DESCRIPTION
    Takes a parameter and a value, stores it in a hash table, and then exports to a file.

.PARAMETER Name
    String value for the script state to store (State, Hostname, etc.)

.PARAMETER Value
    Value for the stored parameter (1, 2, DC01, etc.)

.PARAMETER StateFile
    Location of the script statefile. Script expects CSV format.

.EXAMPLE
    .\Set-ScriptState -Name State -Value 1
#>


[CmdletBinding()]
param(
    [Parameter(Mandatory = $True,
               ValueFromPipeline = $True)]
    [string]$Name,

    [Parameter(Mandatory = $True,
               ValueFromPipeline = $True)]
    $Value,

    [Parameter(Mandatory = $False,
               ValueFromPipeline = $False)]
    [string]$StateFile = "${$PSScriptRoot}scriptstate.csv"
    )

begin {
    #Check for existence of the script state file, import as PSObject if found
    if(Test-Path $StateFile){
        $state = Import-Csv -Path $StateFile
    }

    #Instantiate a new PSObject to hold our state
    else{
        $state = New-Object -TypeName PSObject
    }
}

process {
    #Update state with supplied values. The Force switch overwrites existing value if present
    Add-Member -InputObject $state -Name $Name -Value $Value -MemberType NoteProperty -Force
}

end {
    #Dump script state to a file
    Export-Csv -InputObject $state -Path $StateFile -NoTypeInformation
}
