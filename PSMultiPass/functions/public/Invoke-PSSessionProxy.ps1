
<#
.SYNOPSIS
    Creates PSSession connections to multiple remote computers with error handling.

.DESCRIPTION
    This function establishes PSSession connections to multiple computers in parallel with
    throttled connection attempts. It handles connection errors gracefully and returns both
    successful sessions and connection error information.
    
    Useful as a foundation for remote command execution or as a prerequisite for other
    remote administration tasks.

.PARAMETER ComputerName
    An array of computer names or IP addresses to establish PSSession connections with.

.PARAMETER Credential
    PSCredential object containing the username and password for remote authentication.

.PARAMETER SessionOption
    Optional PSSessionOption object to customize session connection behavior.
    Examples: SkipCertificateCheck, SkipCACheck, SkipRevocationCheck for remote connections.
    If not specified, default session options are used.

.PARAMETER SessionThrottleLimit
    The maximum number of concurrent PSSession connection attempts.
    Default value is 32. Higher values allow faster bulk session creation on capable systems.

.EXAMPLE
    PS> $cred = Get-Credential
    PS> $computers = @("Server1", "Server2", "Server3", "Server4")
    PS> $result = Invoke-PSSessionProxy -ComputerName $computers -Credential $cred -SessionThrottleLimit 10
    PS> $result.Sessions
    
    Creates PSSession connections to four servers with a maximum of 10 concurrent connections.

.EXAMPLE
    PS> $computers = @("RemoteHost1", "RemoteHost2")
    PS> $opts = New-PSSessionOption -SkipCertificateCheck
    PS> $result = Invoke-PSSessionProxy -ComputerName $computers -Credential $cred -SessionOption $opts
    PS> $result.SessionErrorInfo
    
    Creates sessions with custom options and displays any connection errors.

.OUTPUTS
    PSCustomObject with the following properties:
    - Sessions: Array of successfully created PSSession objects
    - SessionErrorInfo: Array of connection failures with error details

.NOTES
    - Connection errors are captured but do not stop the function from attempting other connections
    - Sessions are returned as PSSession objects ready for use with Invoke-Command
    - Use SessionThrottleLimit to balance speed vs. system resource usage
    - Sessions must be cleaned up manually using Remove-PSSession when finished

.LINK
    New-PSSession
    Invoke-Command
    Remove-PSSession
    New-PSSessionOption
#>
function Invoke-PSSessionProxy {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [string[]]
        $ComputerName,

        [Parameter(Mandatory = $true)]
        [pscredential]
        $Credential,

        [System.Management.Automation.Remoting.PSSessionOption]
        $SessionOption = $null,

        [int]
        $SessionThrottleLimit = 32

    )

    Begin {
        $sessionParameters = @{
            ComputerName = $ComputerName 
            Credential = $Credential
            ThrottleLimit = $SessionThrottleLimit
            ErrorVariable = 'sessionError'
            ErrorAction = 'SilentlyContinue'
        }

        if ($SessionOption) { $sessionParameters.Add('SessionOption', $SessionOption)}

        Write-Verbose "Creating sessions for the following computer names: $($ComputerName -join ', ') with throttle limit of $SessionThrottleLimit..."
        $sessions = New-PSSession @sessionParameters

        $sessionErrorInfo = $sessionError.TargetObject

        if ($sessionError) {
            Write-Warning "One or more sessions were not created successfully. Please check the SessionErrorInfo property."
        }

        $sessionCount = $sessions.Count
        Write-Verbose "Successfully created $sessionCount sessions."
        
    }

    End {

        $output = [PSCustomObject]@{
            Sessions = $sessions
            SessionErrorInfo = $sessionErrorInfo
        }

        Write-Output $output
        
    }
}