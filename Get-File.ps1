<#
.SYNOPSIS
Loops recursively through a directory and downloads specified files.

.DESCRIPTION
Takes string, array, or file input and retrieves all files matching the pattern.

.PARAMETER Path
Target path.

.PARAMETER FileList
Target file or files.

.PARAMETER InputList
File containing target files, one per line.

.PARAMETER OutPath
Location to copy files to

.EXAMPLE
PS>Get-File.ps1 -Path C:\Path\To\Files -InputList files.txt -OutPath
#>

[CmdletBinding()]

Param (
    [Parameter(Mandatory = $True)]
    [ValidateScript({Test-Path -Path $_})]
    [string]
    $Path,
    [Parameter(Mandatory = $True,
               ParameterSetName = 'StringOrArray',
               ValueFromPipeline = $True)]
    [string[]]
    $TargetFiles,
    [Parameter(Mandatory = $True,
               ParameterSetName = 'InputList',
               ValueFromPipeline = $True)]
    [ValidateScript({Test-Path -Path $_})]
    [string]
    $TargetList,
    [Parameter(Mandatory = $True)]
    [ValidateScript({Test-Path -Path $_})]
    [string]
    $OutputPath
)

if ($TargetList) {
    Write-Verbose -Message '[*] InputList found, importing...'
    $TargetFiles = Get-Content -Path $TargetList
}

$FileList = Get-ChildItem -Path $Path -Recurse -File

foreach ($File in $FileList) {
    if ($TargetFiles -contains $File.Name) {
        Write-Verbose -Message "[+] Found match: $($File.Name)"
        Copy-Item -Path $File.FullName -Destination $OutputPath
    }
}
