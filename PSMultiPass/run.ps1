
Import-Module 'C:\code\Github\PSMultiPass\PSMultiPass\PSMultiPass.psm1' -Force

$throttleLimit = 20

Invoke-ForEachParallelProxy -InputObject (1..100) -ScriptBlock {
    $random = Get-Random -Minimum 1 -Maximum 5
    Write-Host "Processing item $_ in $random seconds - Test1=$test1, Test2=$test2, Test3=$test3"
    Start-Sleep -Seconds $random
} -ImportUserVariables -ThrottleLimit $throttleLimit -Verbose -IncludeUserVariableName @('Test3')

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
    $Bag.Add("Test " + $_ + ' ' + $test3)
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