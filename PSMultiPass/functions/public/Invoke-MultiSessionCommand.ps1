
### Possibly change functionality to include just creating sessions using error checking on
### failed sessions and returning sessions as an output.


function Invoke-MultiSessionCommand {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [string[]]
        $ComputerName,

        [Parameter(Mandatory = $true)]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true)]
        [ScriptBlock]$ScriptBlock,

        [int]
        $CommandThrottleLimit = 10,

        [System.Management.Automation.Remoting.PSSessionOption]
        $SessionOption = $null,

        [string[]]
        $SessionName,

        [int]
        $SessionThrottleLimit = 32
    )


    Begin {
        $sessionParameters = @{
            ComputerName = $ComputerName 
            Credential = $Credential
            ThrottleLimit = $SessionThrottleLimit
            ErrorVariable = 'sessionError'
            # ErrorAction = 'SilentlyContinue'
        }

        if ($SessionOption) { $sessionParameters.Add('SessionOption', $SessionOption)}
        if ($SessionName) { $sessionParameters.Add('Name', $SessionName)}

        $sessions = New-PSSession @sessionParameters

        # $sessions = New-PSSession -ComputerName $ComputerName -Credential $Credential -ErrorAction SilentlyContinue -ErrorVariable SessionError

        # Write-Output $sessionError

        
    }

    Process {
        # $commandParameters = @{
        #     Session = $sessions
        #     ScriptBlock = $ScriptBlock
        #     ThrottleLimit = $CommandThrottleLimit
        # }
        
        # Invoke-Command @commandParameters
        
        # Write-Output $sessions
    }

    End {
        # Clean up all sessions
        # TODO: Add parameter to prompt for cleaning up sessions? Default to True or False?
        # Remove-PSSession -Session $sessions -ErrorAction $ErrorActionPreference
    }
}