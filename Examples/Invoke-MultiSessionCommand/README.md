# Invoke-MultiSessionCommand - Examples
Creates PSSessions to the provided Computer Names then invokes a `scriptblock` against those sessions and returns the results

This function utilizes the Invoke-PSSessionProxy function from this module to create PowerShell sessions then invokes the provided `scriptblock` against those sessions. Use the `-CommandThrottleLimit` parameter to control how many session commands to run at a time.

### Install the module

```powershell
Install-Module -Name PSMultiPass 
```

### Example - Querying Services Across Multiple Servers and Handling Connection Errors

#### Define credential and Scriptblock variables:

```powershell

# Credential for remote sessions
$credential = Get-Credential

# Define the script block to execute remotely
$scriptBlock = {
    Get-Service -Name BITS
}
```
#### Specify target computer names (We're expecting testxx to fail for this example):

```powershell
$computerNames = @("test01", "test02", "testxx")
```

#### Execute the script block across multiple sessions. Store the rsults in the variable `$result`:

```powershell
$result = Invoke-MultiSessionCommand -ComputerName $computerNames -Credential $credential -ScriptBlock $scriptBlock
```

`$result` variable has 3 properties: `CommandOutput`, `SessionErrorInfo`, and `CommandErrorInfo`

```powershell
# Display all properties
$result 

CommandOutput SessionErrorInfo          CommandErrorInfo
------------- -------------------       ----------------
{BITS, BITS}  System.Management.Auto... 
```

#### `CommandOutput` is an Array containing the outputs of your remote executions:

```powershell
# Access successful command output from each session:
$result.CommandOutput 

Status   Name               DisplayName                            PSComputerName
------   ----               -----------                            --------------
Stopped  BITS               Background Intelligent Transfer Servi… test01
Stopped  BITS               Background Intelligent Transfer Servi… test02
```

#### If there were any connection errors, they will be under the `SessionErrorInfo` property:

```powershell
$result.SessionErrorInfo

Id Name            ComputerName    Type          State         Availability
 -- ----            ------------    ----          -----         ------------
 22 Runspace22      testxx          Remote        Broken        None
```

#### To get more connection error information, you can select all properties:

```powershell
$result.SessionErrorInfo | select *

InitialSessionState    : 
JobManager             : 
Version                : 7.5.5
RunspaceStateInfo      : Broken
ThreadOptions          : Default
RunspaceAvailability   : None
ConnectionInfo         : System.Management.Automation.Runspaces.WSManConnectionInfo
OriginalConnectionInfo : System.Management.Automation.Runspaces.WSManConnectionInfo
Events                 : 
Debugger               : 
ApartmentState         : Unknown
RunspaceIsRemote       : True
InstanceId             : adba7949-295e-4e59-8610-90bb53e2bada
DisconnectedOn         : 
ExpiresOn              : 
Name                   : Runspace22
Id                     : 22
SessionStateProxy      : System.Management.Automation.RemoteSessionStateProxy
```

#### If you want to get the failing computer name and see the connection info for each session, use the `ConnectionInfo` property:

```powershell
$result.SessionErrorInfo.ConnectionInfo

ConnectionUri                     : http://testxx/wsman
ComputerName                      : testxx
Scheme                            : http
Port                              : 80
AppName                           : wsman
Credential                        : System.Management.Automation.PSCredential
ShellUri                          : http://schemas.microsoft.com/powershell/Microsoft.PowerShell
AuthenticationMechanism           : Default
CertificateThumbprint             : 
MaximumConnectionRedirectionCount : 0
MaximumReceivedDataSizePerCommand : 
MaximumReceivedObjectSize         : 209715200
UseCompression                    : True
NoMachineProfile                  : False
ProxyAccessType                   : None
ProxyAuthentication               : Negotiate
ProxyCredential                   : 
SkipCACheck                       : False
SkipCNCheck                       : False
SkipRevocationCheck               : False
NoEncryption                      : False
UseUTF16                          : False
OutputBufferingMode               : None
IncludePortInSPN                  : False
EnableNetworkAccess               : False
MaxConnectionRetryCount           : 5
Culture                           : en-US
UICulture                         : en-US
OpenTimeout                       : 180000
CancelTimeout                     : 60000
OperationTimeout                  : 180000
IdleTimeout                       : -1
MaxIdleTimeout                    : 2147483647
```

#### If there were any command execution errors, they will be under the `CommandErrorInfo` property:

```powershell
$result.CommandErrorInfo

Write-Error: This is an error message
```

#### To see command errors with detailed information:

```powershell
# Get detailed command error information
$result.CommandErrorInfo | Select-Object *

PSMessageDetails      : 
OriginInfo            : test01
Exception             : System.Management.Automation.RemoteException: This is an error message
TargetObject          : 
CategoryInfo          : NotSpecified: (:) [Write-Error], WriteErrorException
FullyQualifiedErrorId : Microsoft.PowerShell.Commands.WriteErrorException,Microsoft.PowerShell.Commands.WriteErrorCommand
ErrorDetails          : 
InvocationInfo        : 
ScriptStackTrace      : 
PipelineIterationInfo : {}
```

