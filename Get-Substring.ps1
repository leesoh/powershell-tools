<#
.SYNOPSIS
    Returns values between to strings.

.DESCRIPTION
    Takes start and end character, returns the middle.

.PARAMETER Start
    Start string.

.PARAMETER End
    End string.

.PARAMETER Path
    Path to file

.EXAMPLE
    Get-Substring -Start 'Hello' -End 'Peanut' -Path C:\Path\To\File
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $True,
               ValueFromPipeline = $True)]
    [string]$Start,

    [Parameter(Mandatory = $True,
               ValueFromPipeline = $True)]
    [string]$End,

    [Parameter(Mandatory = $True,
               ValueFromPipeline = $True)]
    [string]$Path
)

# Need to get multi-line working
[regex]$Pattern = "(?<=$Start).*?(?=$End)"

# Store matches in Pattern
$Results = Select-String -Path $Path -Pattern $Pattern

# Return the value of the first match
$Results.Matches[0].Value
