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

.EXAMPLE
    Get-Base -String 'Hello World!'

.EXAMPLE
    Get-Base -Base64 'SGVsbG8gV29ybGQh'

#>

[CmdletBinding()]

param (
    [Parameter(Mandatory = $True,
               ParameterSetName = 'Base64')]
    [string]
    $Base64,

    [Parameter(Mandatory = $True,
               ParameterSetName = 'String')]
    [string]
    $String
)

begin {}

process {
    if ($Base64) {
        $Result = [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($Base64))
    }

    elseif ($String) {
        $Result = [System.Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($String))
    }
}

end {
    $Result
}
