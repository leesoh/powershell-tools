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

    [Parameter(Mandatory = $false)]
    [switch]$Greedy
)

$GreedyValue = 0

if($Greedy){
    $GreedyValue = 1
}
#Retrieve the index for the start slice and subtract one to include
[int]$StartIndex = (Select-String $Text -Pattern $StartSlice)[0].LineNumber - $GreedyValue

#Retrieve the index for the end slice and subtract one to include
[int]$EndIndex = (Select-String $Text -Pattern $EndSlice)[0].LineNumber - $GreedyValue

#Slice!
$Slice = (Get-Content $Text)[$StartIndex..$EndIndex]
$Slice
