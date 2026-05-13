
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

        [int]
        $SessionThrottleLimit = 32,

        [bool]
        $CleanUpSessions = $true
    )

    Begin {
        $sessionParameters = @{
            ComputerName = $ComputerName 
            Credential = $Credential
            SessionThrottleLimit = $SessionThrottleLimit
            ErrorVariable = 'sessionError'
            ErrorAction = 'SilentlyContinue'
        }

        if ($SessionOption) { $sessionParameters.Add('SessionOption', $SessionOption)}

        $sessionResults = Invoke-PSSessionProxy @sessionParameters

        $sessions = $sessionResults.Sessions
        $sessionCount = $sessions.Count
        $connectionErrorInfo = $sessionResults.ConnectionErrorInfo
        
    }

    Process {

        if ($sessionCount -eq 0) {
            Write-Warning "No sessions were created successfully. Skipping command invocation."
            return
        }

        Write-Verbose "Invoking command on $sessionCount sessions with throttle limit of $CommandThrottleLimit..."
        
        $commandParameters = @{
            Session = $sessions
            ScriptBlock = $ScriptBlock
            ThrottleLimit = $CommandThrottleLimit
            ErrorVariable = 'commandError'
        }
        
        $commandOutput = Invoke-Command @commandParameters 
    
    }

    End {

        $output = [PSCustomObject]@{
            CommandOutput = $commandOutput
            ConnectionErrorInfo = $connectionErrorInfo
        }

        Write-Output $output
        
        if ($CleanUpSessions -and $sessionCount -gt 0) {
            # Clean up all sessions
            Write-Verbose "Cleaning up sessions..."            
            Remove-PSSession -Session $sessions -ErrorAction $ErrorActionPreference
        }
        
    }
}