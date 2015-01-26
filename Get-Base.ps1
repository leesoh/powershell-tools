<#
.SYNOPSIS
	PowerShell script to encode text to Base64 and back again.
.DESCRIPTION
    Copyright (C) 2014 Liam Somerville

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along
    with this program; if not, write to the Free Software Foundation, Inc.,
    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
.NOTES
    Author: Liam Somerville
.EXAMPLE
    Get-Base -String 'Hello World!'
.EXAMPLE
    Get-Base -Base64 'SGVsbG8gV29ybGQh'
#>

[CmdletBinding()]
Param
    (
        [parameter(Mandatory=$false)]
        [string]
        $Base64,

        [parameter(Mandatory=$false)]
        [string]
        $String
    )

function Write-Header($Title)
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

function ConvertTo-Base($String)
{
    $Base64 = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($String))
    $Base64
} # end ConvertTo-Base

function ConvertFrom-Base($Base64)
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
} # end else
Write-Host
