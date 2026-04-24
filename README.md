# PSMultiPass
A PowerShell module focusing on running parallel automation

This module started out as a way to run `ForEach-Object -Parallel` without having to worry about scoping my variables within my scriptblocks using the "$Using:variableName" format.

The first command for this module is `Invoke-ForEachParallelProxy`, which can be used to import variables from the current scope into the parallel sessions created by `ForEach-Object -Parallel`. This idea came while reviewing the code for [Invoke-Parallel](https://github.com/RamblingCookieMonster/Invoke-Parallel) which was developed by Warren Frame ([RamblingCookieMonster](https://github.com/RamblingCookieMonster))

## Usage
```powershell
# Install Module
Install-Module PSMultiPass

$testVariable1 = 'TestValue1'
$testVariable2 = 'TestValue2'

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
