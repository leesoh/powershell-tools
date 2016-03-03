<#
.SYNOPSIS
    Returns a slice from a block of text.

.DESCRIPTION
    Takes two parameters: start and end pattern. Returns those and everything in between.

.PARAMETER Path
    Target file

.PARAMETER Start
    Start pattern

.PARAMETER End
    End pattern

.PARAMETER StartOffset
    Offset to found start string. Defaults to -1 which includes Start

.PARAMETER EndOffset
    Offset to found end string. Defaults to -1 which includes up to End

.EXAMPLE
    .\Get-Slice.ps1 -Path "sample.txt" -Start "The quick brown" -End "lazy dog"

.EXAMPLE
    .\Get-Slice.ps1 -Path "sample.txt" -Start "The quick brown" -End "lazy dog" -StartOffset -2
    -EndOffset -2
#>

[CmdletBinding()]

Param (
    [Parameter(Mandatory = $true,
               ValueFromPipeline = $true)]
    [ValidateScript({Test-Path $_})]
    [string]$Path,

    [Parameter(Mandatory = $true,
               ValueFromPipeline = $true)]
    [string]$Start,

    [Parameter(Mandatory = $true,
               ValueFromPipeline = $true)]
    [string]$End,

    [Parameter(Mandatory = $false)]
    [int]$StartOffset = 0,

    [Parameter(Mandatory = $false)]
    [int]$EndOffset = -1
)

#Retrieve the index for the start slice and subtract one to include
$StartIndex = (Select-String -Pattern $Start -Path $Path -SimpleMatch)[0].LineNumber + $StartOffset

#Retrieve the index for the end slice and subtract one to include
$EndIndex = (Select-String -Pattern $End -Path $Path -SimpleMatch)[0].LineNumber + $EndOffset

#Slice!
$Slice = (Get-Content $Path)[$StartIndex..$EndIndex]
$Slice
