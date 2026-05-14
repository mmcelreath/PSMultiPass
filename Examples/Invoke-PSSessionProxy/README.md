# Invoke-PSSessionProxy - Examples
Creates PSSession connections to multiple remote computers with error handling and throttling.

This function establishes PSSession connections to multiple computers in parallel with throttled connection attempts. It handles connection errors gracefully and returns both successful sessions and connection error information.

### Install the module

```powershell
Install-Module -Name PSMultiPass 
```

### Example - Creating Sessions to Multiple Servers with Connection Error Handling

#### Define credential and computer names:

```powershell
# Credential for remote sessions
$credential = Get-Credential

# Target computer names (We're expecting testxx to fail for this example)
$computerNames = @("test01", "test02", "testxx")
```

#### Create PSSession connections with throttled connection attempts:

```powershell
$result = Invoke-PSSessionProxy -ComputerName $computerNames -Credential $credential -SessionThrottleLimit 10
```

`$result` variable has 2 properties: `Sessions` and `SessionErrorInfo`

```powershell
# Display the result
$result 

Sessions                                                                       SessionErrorInfo
--------                                                                       ----------------
{System.Management.Automation.Runspaces.PSSession}                            System.Management.Automation.RemoteRunspace
```

#### `Sessions` contains an array of successfully created PSSession objects:

```powershell
# Access successful sessions
$result.Sessions 

 Id Name            ComputerName    Type          State         Availability
 -- ----            ------------    ----          -----         ------------
  1 Runspace1       test01          Remote        Opened        Available
  2 Runspace2       test02          Remote        Opened        Available
```

#### If there were any connection errors, they will be under the `SessionErrorInfo` property:

```powershell
$result.SessionErrorInfo

Id Name            ComputerName    Type          State         Availability
 -- ----            ------------    ----          -----         ------------
 22 Runspace22      testxx          Remote        Broken        None
```

#### To get detailed connection error information:

```powershell
# Get detailed error information for each failed connection
$result.SessionErrorInfo | Select-Object Id, Name, State, RunspaceAvailability

Id Name            State  RunspaceAvailability
-- ----            -----  --------------------
22 Runspace22      Broken None
```

#### To check the connection information for failed connections:

```powershell
# View connection details for failed sessions
$result.SessionErrorInfo.ConnectionInfo

ConnectionUri                     : http://testxx/wsman
ComputerName                      : testxx
Scheme                            : http
Port                              : 80
AppName                           : wsman
Credential                        : System.Management.Automation.PSCredential
```

#### Use sessions with Invoke-Command:

```powershell
# Use the successfully created sessions with Invoke-Command
$output = Invoke-Command -Session $result.Sessions -ScriptBlock { Get-Process -Name svchost }

# View the results from each session
$output
```

#### Common usage pattern - Check for errors before proceeding:

```powershell
# Create sessions and check for errors
$sessionResult = Invoke-PSSessionProxy -ComputerName $computerNames -Credential $credential

if ($sessionResult.Sessions.Count -eq 0) {
    Write-Error "No sessions were created successfully"
    exit
}

if ($sessionResult.SessionErrorInfo) {
    Write-Warning "Some connections failed:"
    $sessionResult.SessionErrorInfo | ForEach-Object {
        Write-Warning "Failed to connect to: $($_.ConnectionInfo.ComputerName)"
    }
}

# Proceed with using the successfully created sessions
$commandOutput = Invoke-Command -Session $sessionResult.Sessions -ScriptBlock { Get-EventLog -LogName System -Newest 5 }

# Clean up sessions
Remove-PSSession -Session $sessionResult.Sessions
```

#### Example - Using custom session options:

```powershell
# Create session options for SSL certificate handling
$sessionOptions = New-PSSessionOption -SkipCertificateCheck

# Create sessions with custom options
$result = Invoke-PSSessionProxy `
    -ComputerName $computerNames `
    -Credential $credential `
    -SessionOption $sessionOptions `
    -SessionThrottleLimit 5

# Check successful sessions
$result.Sessions | Format-Table -Property Name, ComputerName, State
```
