
Import-Module 'C:\code\PSModules\PSMultiPass\PSMultiPass.psm1' -Force

$throttleLimit = 20

Invoke-ForEachParallelProxy -InputObject (1..100) -ScriptBlock {
    $random = Get-Random -Minimum 1 -Maximum 5
    Write-Host "Processing item $_ in $random seconds - Test=$test3"
    Start-Sleep -Seconds $random
} -ImportUserVariables -ThrottleLimit $throttleLimit -Verbose ExcludeUserVariableName @('Test3')


