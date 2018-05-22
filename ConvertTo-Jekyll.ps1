<#
.SYNOPSIS
    Creates a Jekyll-formatted page from a Markdown source.

.DESCRIPTION
    The page is converted using the following rules:

    * Top-level heading is converted to the title
    * File is named in the format <date>-title

.PARAMETER Markdown
    Source markdown file

.PARAMETER PostPath
    Folder containing Jekyll posts

.PARAMETER Tags
    Comma-delimited list of tags for the post

.PARAMETER Date
    Date for post. Defaults to today.

.EXAMPLE
    PS C:\> ConvertTo-Jekyll -Markdown File.md -PostPath C:\Path\To\Jekyll\_posts -Tags computering
#>

function ConvertTo-Jekyll {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            HelpMessage = "Path to Markdown source file.")]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $Markdown,
        [Parameter(Mandatory = $true,
            HelpMessage = "Path to Jekyll _posts folder.")]
        [ValidateNotNullOrEmpty()]
        [string]
        $PostPath,
        # Specifies a path to one or more locations.
        [Parameter(Mandatory = $false,
            HelpMessage = "Tag for post.")]
        [string]
        $Tags,
        [Parameter(Mandatory = $false)]
        [string]
        $Date = (Get-Date).ToString('yyyy-MM-dd')
    )

    begin {
        Write-Output '[*] Work beginning...'
    }

    process {
        foreach ($File in $Markdown) {
            $HeaderPrefix = '# '
            # Retrieve the top-level header
            $OldHeader = (Select-String -Pattern "^$HeaderPrefix" -Path $Markdown).Line

            if ($OldHeader) {
                # Remove header prefix to get the post title
                $Title = $OldHeader.Replace($HeaderPrefix, '')
                # Replace spaces, convert to lowercase
                $Filename = $Title.Replace(' ', '-').ToLower()
                # Prepend Date and add extension
                $Filename = $Date + '-' + $Filename + '.md'
                # Build host header
                $NewHeader = "---`ntitle: $Title`nlayout: post`ntags: [$Tags]`n---"
                # Load post
                $MarkdownContent = Get-Content -Path $Markdown
                # Replace old header with new
                $PostContent = $MarkdownContent.Replace($OldHeader, $NewHeader)
                # Write post to posts directory
                Set-Content -Value $PostContent -Path "$PostPath\$Filename"
            }
            else {
                Write-Output '[-] No header found. Exiting.'
            }
        }
    }

    end {
        Write-Output '[*] Work complete!'
    }
}