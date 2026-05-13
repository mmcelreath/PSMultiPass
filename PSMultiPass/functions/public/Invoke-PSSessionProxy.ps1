
### Possibly change functionality to include just creating sessions using error checking on
### failed sessions and returning sessions as an output.


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

        $connectionErrorInfo = $sessionError.TargetObject

        if ($sessionError) {
            Write-Warning "One or more sessions were not created successfully. Please check the ConnectionErrorInfo property."
        }

        $sessionCount = $sessions.Count
        Write-Verbose "Successfully created $sessionCount sessions."
        
    }

    End {

        $output = [PSCustomObject]@{
            Sessions = $sessions
            ConnectionErrorInfo = $connectionErrorInfo
        }

        Write-Output $output
        
    }
}