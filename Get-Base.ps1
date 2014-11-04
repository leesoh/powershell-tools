<#
.SYNOPSIS
	PowerShell script to encode text to Base64 and back again.
.NOTES
    Author: Liam Somerville
.EXAMPLE
    Get-Base -String 'Hello World!'
.EXAMPLE
    Get-Base -Base64 'SGVsbG8gV29ybGQh'
#>

[CmdletBinding()]
param(
    [parameter(Mandatory=$false)]
    [string]
    $Base64,
    
    [parameter(Mandatory=$false)]
    [string]
    $String
    )

function Write-Header ($Title)
{
    $Gap = '  '
    $Title = $Gap + $Title + $Gap
    $Open = '['
    $Spacer = '='*10
    $Close = ']'
    
    Write-Host
    $Open + $Spacer + $Title + $Spacer + $Close
    Write-Host
} # end Write-Header



function ConvertTo-Base ($String)
{
    $Base64 = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($String))
    $Base64
} # end ConvertTo-Base

function ConvertFrom-Base ($Base64)
{
    $String = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($Base64))
    $String
} # end ConvertFrom-Base

Write-Header('Get-Base v0.1')

if ($Base64)
{
    Write-Host $Base64 '>>>' $(ConvertFrom-Base($Base64))
} # end if

elseif ($String)
{
    Write-Host $String '>>>' $(ConvertTo-Base($String))
} # end elseif

else
{
    Write-Host 'No input received!'    
}
Write-Host