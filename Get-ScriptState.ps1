<#
.SYNOPSIS
    Retrieves script state from persistent state file.

.DESCRIPTION
    Retrieves script state file, stores as PSObject, returns.

.PARAMETER StateFile
    Location of script StateFile

.EXAMPLE
    .\Get-ScriptSate -StateFile C:\statefile.csv
#>


[CmdletBinding()]
param(
    [Parameter(Mandatory = $False,
               ValueFromPipeline = $False)]
    [ValidateScript({Test-Path $_ -PathType 'Leaf'})]
    [string]$StateFile = "${$PSScriptRoot}scriptstate.csv"
    )

$state = Import-Csv -Path $StateFile
$state