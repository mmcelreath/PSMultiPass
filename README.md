# PSMultiPass
A PowerShell module focusing on running parallel automation

This module started out as a way to run `ForEach-Object -Parallel` without having to worry about scoping my variables within my scriptblocks using the "$Using:variableName" format.

The first command for this module is `Invoke-ForEachParallelProxy`, which can be used to import variables from the current scope into the parallel sessions created by `ForEach-Object -Parallel`. This idea came while reviewing the code for [Invoke-Parallel](https://github.com/RamblingCookieMonster/Invoke-Parallel) which was developed by Warren Frame ([RamblingCookieMonster](https://github.com/RamblingCookieMonster))

# Usage

## Invoke-ForeEachParallelProxy

```powershell
# Install Module
Install-Module PSMultiPass

# Set some variables in the current session
$testVariable1 = 'TestValue1'
$testVariable2 = 'TestValue2'

# Invoke ForEach-Object -Parallel, importing the current variables
# Variables can be referenced without having to use the $Using: syntax.
Invoke-ForEachParallelProxy -InputObject (1..5) -ScriptBlock {
    $currentItem = $_
    Write-Host "Session: $currentItem, testVariable1 = $testVariable1, testVariable2 = $testVariable2"
} -ImportUserVariables 

Session: 1, testVariable1 = TestValue1, testVariable2 = TestValue2
Session: 2, testVariable1 = TestValue1, testVariable2 = TestValue2
Session: 3, testVariable1 = TestValue1, testVariable2 = TestValue2
Session: 4, testVariable1 = TestValue1, testVariable2 = TestValue2
Session: 5, testVariable1 = TestValue1, testVariable2 = TestValue2

```

### Using with Thread-Safe variable

```powershell
# Install Module
Install-Module PSMultiPass

# Create thread-safe array for storing results
$Bag = [System.Collections.Concurrent.ConcurrentBag[psobject]]::new()

# Invoke ForEach-Object -Parallel, importing the current variables
# Reference thread-safe variable in scriptblock without the $Using: syntax
Invoke-ForEachParallelProxy -InputObject (1..10) -ScriptBlock { 
    $Bag.Add("Test $_")
} -ThrottleLimit $throttleLimit -ImportUserVariables

# Gather results from thread-safe variable and display them
$results = $Bag.ToArray()
$results

Test 10
Test 9
Test 8
Test 2
Test 5
Test 4
Test 7
Test 1
Test 6
Test 3
```

## Invoke-MultiSessionCommand

```powershell
# Credential for remote sessions
$credential = Get-Credential

# Define the script block to execute remotely
$scriptBlock = {
    Get-Service -Name BITS
}

$computerNames = @("test01", "test02", "testxx")

$result = Invoke-MultiSessionCommand -ComputerName $computerNames -Credential $credential -ScriptBlock $scriptBlock

# Display all properties
$result 

CommandOutput SessionErrorInfo          CommandErrorInfo
------------- -------------------       ----------------
{BITS, BITS}  System.Management.Auto... 

# Access successful command output from each session:
$result.CommandOutput 

Status   Name               DisplayName                            PSComputerName
------   ----               -----------                            --------------
Stopped  BITS               Background Intelligent Transfer Servi… test01
Stopped  BITS               Background Intelligent Transfer Servi… test02

```