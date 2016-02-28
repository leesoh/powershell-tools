<#
.SYNOPSIS
    Returns a slice from a block of text.

.DESCRIPTION
    Takes two parameters: start and end pattern. Returns those and everything in between.

.PARAMETER Path
    Target file

.PARAMETER StartString
    Start pattern

.PARAMETER EndString
    End pattern

.PARAMETER StartOffset
    Offset to found start string. Defaults to -1 which includes StartString

.PARAMETER EndOffset
    Offset to found end string. Defaults to -1 which includes up to EndString
.EXAMPLE
    .\Get-Slice.ps1 -Path "sample.txt" -StartString "The quick brown" -EndString "lazy dog"

.EXAMPLE
    .\Get-Slice.ps1 -Path "sample.txt" -StartString "The quick brown" -EndString "lazy dog" -StartOffset -2
    -EndOffset -2
#>


[CmdletBinding()]
param (
    [Parameter(Mandatory = $true,
               ValueFromPipeline = $true)]
    [ValidateScript({Test-Path $_})]
    [string]$Path,

    [Parameter(Mandatory = $true,
               ValueFromPipeline = $true)]
    [string]$StartString,

    [Parameter(Mandatory = $true,
               ValueFromPipeline = $true)]
    [string]$EndString,

    [Parameter(Mandatory = $false)]
    [int]$StartOffset = 0,

    [Parameter(Mandatory = $false)]
    [int]$EndOffset = -1
)

#Retrieve the index for the start slice and subtract one to include
$StartIndex = (Select-String -Pattern $StartString -Path $Path -SimpleMatch)[0].LineNumber + $StartOffset

#Retrieve the index for the end slice and subtract one to include
$EndIndex = (Select-String -Pattern $EndString -Path $Path -SimpleMatch)[0].LineNumber + $EndOffset

#Slice!
$Slice = (Get-Content $Path)[$StartIndex..$EndIndex]
$Slice
