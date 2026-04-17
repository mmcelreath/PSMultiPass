
Import-Module 'C:\code\Github\PSMultiPass\PSMultiPass\PSMultiPass.psm1' -Force

$throttleLimit = 20

Invoke-ForEachParallelProxy -InputObject (1..100) -ScriptBlock {
    $random = Get-Random -Minimum 1 -Maximum 5
    Write-Host "Processing item $_ in $random seconds - Test1=$test1, Test2=$test2, Test3=$test3"
    Start-Sleep -Seconds $random
} -ImportUserVariables -ThrottleLimit $throttleLimit -Verbose -IncludeUserVariableName @('Test3')



