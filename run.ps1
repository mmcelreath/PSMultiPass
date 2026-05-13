
Import-Module 'C:\code\Github\PSMultiPass\PSMultiPass\PSMultiPass.psm1' -Force

$throttleLimit = 20

$Variable1 = 'Value-1'
$Variable2 = 'Value-2'

Invoke-ForEachParallelProxy -InputObject (1..5) -ScriptBlock {
    Write-Host "Processing item $_ : Variable1=$Variable1, Variable2=$Variable2"
} -ImportUserVariables -IncludeUserVariableName Variable2

Invoke-ForEachParallelProxy -InputObject (1..100) -ScriptBlock {
    $random = Get-Random -Minimum 1 -Maximum 5
    Write-Host "Processing item $_ in $random seconds - Test1=$test1, Test2=$test2, Test3=$test3"
    Start-Sleep -Seconds $random
} -ImportUserVariables -ThrottleLimit $throttleLimit -Verbose -IncludeUserVariableName @('Test3')


$Bag = [System.Collections.Concurrent.ConcurrentBag[psobject]]::new()

Invoke-ForEachParallelProxy -InputObject (1..5) -ScriptBlock {
    $object = [PSCustomObject]@{
        Item = $_
        Variable1 = $Variable1
        Variable2 = $Variable2
    }
    
    $Bag.Add($object)
} -ImportUserVariables 

$results = $Bag.ToArray()
$results



Invoke-ForEachParallelProxy -InputObject (1..100) -ScriptBlock {
    $random = Get-Random -Minimum 1 -Maximum 5
    Write-Host "Processing item $_ in $random seconds - Test1=$test1, Test2=$test2, Test3=$test3"
    Start-Sleep -Seconds $random
} -ThrottleLimit $throttleLimit 



Invoke-ForEachParallelProxy -InputObject (1..1) -ScriptBlock {
    $random = Get-Random -Minimum 1 -Maximum 5
    Write-Host "Processing item $_ in $random seconds - Test1=$test1, Test2=$test2, Test3=$test3"
    Start-Sleep -Seconds $random
} -ImportUserVariables -ThrottleLimit $throttleLimit -Verbose 




$Bag = [System.Collections.Concurrent.ConcurrentBag[psobject]]::new()

Invoke-ForEachParallelProxy -InputObject (1..10) -ScriptBlock {
    $resultsBag = $Using:Bag
    $random = Get-Random -Minimum 1 -Maximum 5
    Write-Host "Processing item $_ in $random seconds - Test1=$test1, Test2=$test2, Test3=$test3"
    Start-Sleep -Seconds $random
    $resultsBag.Add($random)
} -ThrottleLimit $throttleLimit 

$results = $Bag.ToArray()
$results

(1..10) | ForEach-Object -Parallel {
    $resultsBag = $Using:Bag
    $random = Get-Random -Minimum 1 -Maximum 5
    Write-Host "Processing item $_ in $random seconds - Test1=$test1, Test2=$test2, Test3=$test3"
    Start-Sleep -Seconds $random
    $resultsBag.Add($random)
}




$throttleLimit = 20

Invoke-ForEachParallelProxy -InputObject (1..1) -ScriptBlock {
    $random = Get-Random -Minimum 1 -Maximum 5
    Write-Host "Processing item $_ in $random seconds - Test1=$test1, Test2=$test2, Test3=$test3"
    Start-Sleep -Seconds $random
    Write-Output $random
} -ImportUserVariables -ThrottleLimit $throttleLimit -AsJob






$test3 = 'zzzzzz'

Invoke-ForEachParallelProxy -InputObject (1..10) -ScriptBlock { 
    $test = $Using:test3
    Write-Host $test
} -ThrottleLimit $throttleLimit 



$Bag = [System.Collections.Concurrent.ConcurrentBag[psobject]]::new()

Invoke-ForEachParallelProxy -InputObject (1..10) -ScriptBlock { 
    $Bag.Add("Test $_")
} -ThrottleLimit $throttleLimit -ImportUserVariables

$results = $Bag.ToArray()
$results


$Bag = [System.Collections.Concurrent.ConcurrentBag[psobject]]::new()

Invoke-ForEachParallelProxy -InputObject (1..10) -ScriptBlock { 
    $currentBag = $Using:Bag
    $currentBag.Add("Test " + $_ + ' ' + $test3)
} -ThrottleLimit $throttleLimit

$results = $Bag.ToArray()
$results


$testVariable1 = 'TestValue1'
$testVariable2 = 'TestValue2'

Invoke-ForEachParallelProxy -InputObject (1..5) -ScriptBlock {
    $currentItem = $_
    Write-Host "Session: $currentItem, testVariable1 = $testVariable1, testVariable2 = $testVariable2"
} -ImportUserVariables 



$scriptBlock = {                                                                                    
    Add-WindowsFeature Web-Server -Verbose -WhatIf 
}

$test = Invoke-MultiSessionCommand -ComputerName core01,core02,core03 -ScriptBlock $scriptBlock -Credential $cred -Verbose

