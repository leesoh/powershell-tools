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
<<<<<<< HEAD
param(
    [parameter(Mandatory=$false)]
    [string]
    $Base64,
    
    [parameter(Mandatory=$false)]
    [string]
    $String
)

function Write-Header ($Title) {
=======
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
>>>>>>> c918bbd807d6169ded485a1e22a9c2bb7794400e
    $Gap = '  '
    $Title = $Gap + $Title + $Gap
    $Open = '['
    $Spacer = '='*10
    $Close = ']'

    Write-Host
    $Open + $Spacer + $Title + $Spacer + $Close
    Write-Host
}

<<<<<<< HEAD
function ConvertTo-Base ($String) {
=======
function ConvertTo-Base($String)
{
>>>>>>> c918bbd807d6169ded485a1e22a9c2bb7794400e
    $Base64 = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($String))
    $Base64
}

<<<<<<< HEAD
function ConvertFrom-Base ($Base64) {
=======
function ConvertFrom-Base($Base64)
{
>>>>>>> c918bbd807d6169ded485a1e22a9c2bb7794400e
    $String = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($Base64))
    $String
}

Write-Header('Get-Base v0.1')

if ($Base64) {
    Write-Host $Base64 '>>>' $(ConvertFrom-Base($Base64))
}

elseif ($String) {
    Write-Host $String '>>>' $(ConvertTo-Base($String))
}

<<<<<<< HEAD
else {
    Write-Host 'No input received!'    
}

Write-Host
=======
else
{
    Write-Host 'No input received!'
} # end else
Write-Host
>>>>>>> c918bbd807d6169ded485a1e22a9c2bb7794400e
