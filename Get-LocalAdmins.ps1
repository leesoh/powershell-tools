function Get-LocalMembership {
    [CmdletBinding()]
    param (
        $Group = 'Administrators'
    )

    begin {
    }

    process {
        $NetOutput = Invoke-Expression -Command "net localgroup $Group"
        # Grab from start of member output (after ----) to end of member output
        $Members = $NetOutput[6..($NetOutput.Length - 3)]
        $Properties = @{'Group' = $Group;
                        'Members' = $Members}
        $Properties
    }

    end {
    }
}
