<#
.SYNOPSIS
    Returns a slice from a block of text.

.DESCRIPTION
    Takes two parameters: start and end pattern. Returns everything in between.

.PARAMETER Text
    Block of text to slice.

.PARAMETER StartSlice
    Start pattern

.PARAMETER EndSlice
    End pattern

.EXAMPLE
    .\Get-Slice.ps1 -Text "sample.txt" -StartSlice "The quick brown" -EndSlice "lazy dog"

.EXAMPLE
    .\Get-Slice.ps1 -Text "sample.txt" -StartSlice "The quick brown" -EndSlice "lazy dog" -Greedy -GreedyStart 1
    -GreedyEnd 5
#>


[CmdletBinding()]
param (
    [Parameter(Mandatory = $true,
        ValueFromPipeline = $true)]
    [string]$Text,

    [Parameter(Mandatory = $true,
        ValueFromPipeline = $true)]
    [ValidateScript({Select-String $Text -Pattern $_})]
    [string]$StartSlice,

    [Parameter(Mandatory = $true,
        ValueFromPipeline = $true)]
    [ValidateScript({Select-String $Text -Pattern $_})]
    [string]$Endslice,

    [Parameter(Mandatory = $false,
        ParameterSetName = 'Greedy')]
    [switch]$Greedy,

    [Parameter(Mandatory = $false,
        ParameterSetName = 'Greedy')]
    [int]$GreedyStart = 1,

    [Parameter(Mandatory = $false,
        ParameterSetName = 'Greedy')]
    [int]$GreedyEnd = 1
)

#Retrieve the index for the start slice and subtract one to include
[int]$StartIndex = (Select-String $Text -Pattern $StartSlice)[0].LineNumber + $GreedyStart

#Retrieve the index for the end slice and subtract one to include
[int]$EndIndex = (Select-String $Text -Pattern $EndSlice)[0].LineNumber - $GreedyEnd

#Slice!
$Slice = (Get-Content $Text)[$StartIndex..$EndIndex]
$Slice
