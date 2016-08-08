function Export-FileList {
    <#
    .SYNOPSIS
    Connects to a target and downloads a full list of files.

    .DESCRIPTION

    .NOTES
    Author:  Liam Somerville
    License: GNU GPLv3

    .PARAMETER ComputerName
    String or array containing target computer(s).

    .PARAMETER Path
    Optional parameter containing the target path.

    .PARAMETER OutPath
    Location to store output files.

    .EXAMPLE
    PS C:\> Export-FileList -ComputerName FOO1
    #>

    [CmdletBinding()]

    Param (
        [Parameter(Mandatory = $True,
                   ValueFromPipeline = $True)]
        [string[]]
        $ComputerName,

        [string]
        $Drive = 'C',

        [string]
        $Directory,

        [string]
        [ValidateScript({Test-Path -Path $_})]
        #$OutputPath = (Split-Path -Parent -Path $MyInvocation.MyCommand.Definition),
        $OutputPath = ".\",

        [System.Management.Automation.PSCredential]
        $Credential = [Management.Automation.PSCredential]::Empty
    )

    begin {
        Write-Verbose -Message "[*] Beginning file enumeration..."
    }

    process {
        foreach ($Computer in $ComputerName) {
            $OutputFile = Join-Path -Path $OutputPath -ChildPath "$Computer-files.csv"
            $DriveName = $Computer.Replace(".", "-")
            #TODO: This is causing weird nesting when more than one computer is targeted.
            $TargetPath = Join-Path -Path "\\$Computer" -ChildPath "$Drive`$" | Join-Path -ChildPath $Directory
            Write-Verbose -Message "[*] Now processing $TargetPath..."

            try {
                $Drive = New-PSDrive -Name $DriveName -PSProvider FileSystem -Root $TargetPath -Credential $Credential
            }
            catch {
                Write-Error -Message "[-] Unable to connect to $Computer!"
                Continue
            }

            # We pipe to PSIsContainer rather than use -File for PowerShell v2.0 compliance
            Get-ChildItem -Path $Drive.Root -Recurse -ErrorAction SilentlyContinue |
            Where-Object {!$_.PSIsContainer} |
            Select-Object FullName, @{Name='Owner'; Expression={(Get-Acl $_.FullName).Owner}},
                          LastAccessTime, LastWriteTime, Length | Export-CSV -NoTypeInformation -Path $OutputFile
            Write-Verbose -Message "[+] $Computer results: $OutputFile"
            Remove-PSDrive $DriveName
        }
    }

    end {

        Write-Verbose -Message "[*] Work complete!"
    }
}

function Get-File {
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
}
