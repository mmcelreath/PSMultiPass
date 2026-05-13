# Invoke-MultiSessionCommand - Examples
Creates PSSessions to the provided Computer Names then invokes a `scriptblock` against those sessions and returns the results

This function utilizes the Invoke-PSSessionProxy function from this module to create PowerShell sessions then invokes the provided `scriptblock` against those sessions. Use the `-CommandThrottleLimit` parameter to control how many session commands to run at a time.

### Install the module

```powershell
Install-Module -Name PSMultiPass 
```

### Example - Querying Services Across Multiple Servers and Handling Connection Errors

```powershell

# Credential for remote sessions
$credential = Get-Credential

# Define the script block to execute remotely
$scriptBlock = {
    Get-Service -Name BITS
}

# Specify target computer names (We're expecting testxx to fail for this example)
$computerNames = @("test01", "test02", "testxx")

# Execute the script block across multiple sessions
$result = Invoke-MultiSessionCommand -ComputerName $computerNames -Credential $credential -ScriptBlock $scriptBlock

# Display CommandOutput and ConnectionErrorInfo
$result 

CommandOutput ConnectionErrorInfo
------------- -------------------
{BITS, BITS}  System.Management.Automation.RemoteRunspace

# Access successful command output from each session:
$result.CommandOutput 

Status   Name               DisplayName                            PSComputerName
------   ----               -----------                            --------------
Stopped  BITS               Background Intelligent Transfer Servi… test01
Stopped  BITS               Background Intelligent Transfer Servi… test02

# If there were any connection errors, you can check them like this:
$result.ConnectionErrorInfo

Id Name            ComputerName    Type          State         Availability
 -- ----            ------------    ----          -----         ------------
 22 Runspace22      testxx          Remote        Broken        None

# To get more connection error information, you can select all properties:
$result.ConnectionErrorInfo | select *

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

# If you want to get the failing computer name and see the connection info for each session, you can access it like this:
$result.ConnectionErrorInfo.ConnectionInfo

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

