
<#
.SYNOPSIS
    Executes a script block on multiple remote computers using PSSession.

.DESCRIPTION
    This function creates PSSession connections to multiple computers and executes a script block
    in parallel across all sessions. It handles session creation with error checking, command
    execution with throttling, and automatic session cleanup.
    
    Returns an object containing command output and connection error information for failed connections.

.PARAMETER ComputerName
    An array of computer names or IP addresses to connect to for command execution.

.PARAMETER Credential
    PSCredential object containing the username and password for remote authentication.

.PARAMETER ScriptBlock
    The script block to execute on each remote computer.

.PARAMETER CommandThrottleLimit
    The maximum number of commands to execute in parallel across sessions.
    Default value is 10.

.PARAMETER SessionOption
    Optional PSSessionOption object to customize session connection behavior.
    If not specified, default session options are used.

.PARAMETER SessionThrottleLimit
    The maximum number of PSSession connections to establish in parallel during creation.
    Default value is 32.

.PARAMETER CleanUpSessions
    Switch to automatically remove all PSSession connections after command execution.
    Default is $true. Set to $false to keep sessions open for reuse.

.EXAMPLE
    PS> $cred = Get-Credential
    PS> $computers = @("Server1", "Server2", "Server3")
    PS> $result = Invoke-MultiSessionCommand -ComputerName $computers `
    PS>     -Credential $cred -ScriptBlock { Get-Process -Name svchost } -CommandThrottleLimit 5
    PS> $result.CommandOutput
    
    Retrieves svchost processes from three servers in parallel.

.EXAMPLE
    PS> $computers = @("Server1", "Server2")
    PS> $result = Invoke-MultiSessionCommand -ComputerName $computers `
    PS>     -Credential $cred -ScriptBlock { whoami } -CleanUpSessions $false
    PS> $result.ConnectionErrorInfo
    
    Executes whoami command and keeps sessions open for reuse. Check ConnectionErrorInfo for connection failures.

.NOTES
    - Failed connections are tracked in the ConnectionErrorInfo property of the output
    - Sessions are cleaned up by default unless CleanUpSessions is set to $false
    - Use SessionOption to customize connection behavior (e.g., SkipCertificateCheck)
    - CommandThrottleLimit controls parallelism during command execution, not session creation

.LINK
    Invoke-PSSessionProxy
    New-PSSession
    Invoke-Command
    Remove-PSSession
#>
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