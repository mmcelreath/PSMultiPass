Describe 'Module Manifest Tests' {
    It 'Passes Test-ModuleManifest' {
        $ModuleName = 'PSMultiPass'
        $ModuleManifestName = "$ModuleName.psd1"
        $ModuleManifestPath = Join-Path (Split-Path (Split-Path $PSCommandPath)) $ModuleManifestName
        Test-ModuleManifest -Path $ModuleManifestPath | Should -Not -BeNullOrEmpty
        $? | Should -Be $true
    }
}

Describe 'ForEach Parallel Tests' {
    BeforeAll {
        Import-Module .\PSMultiPass\ -Force -Verbose
    }
    
    It 'Passes Invoke ForEach Parallel' {
        $throttleLimit = 25
        Invoke-ForEachParallelProxy -InputObject (1..100) -ScriptBlock {
            "Testing..." | Out-Null
        } -ThrottleLimit $throttleLimit
    }
    
    It 'Passes Invoke ForEach Parallel with User Variables' {
        $throttleLimit = 25
        $Global:testVariable = 'TestValue1'
        $Global:Bag = [System.Collections.Concurrent.ConcurrentBag[psobject]]::new()
        
        Invoke-ForEachParallelProxy -InputObject (1..50) -ScriptBlock {
            if ($testVariable -eq 'TestValue1') {
                $Bag.Add('Succeeded')
            }
        } -ImportUserVariables -ThrottleLimit $throttleLimit 
        
        $results = $Bag.ToArray()

        foreach ($result in $results) {
            $result | Should -Be 'Succeeded'
        }

    }

    It 'Passes Invoke ForEach Parallel with User Variables As a Job' {
        $throttleLimit = 25
        $Global:testVariable = 'TestValue1'

        $job = Invoke-ForEachParallelProxy -InputObject (1..50) -ScriptBlock {
            if ($testVariable -eq 'TestValue1') {
                Write-Output 'Succeeded'
            }
        } -ImportUserVariables -ThrottleLimit $throttleLimit -AsJob

        Get-Job -Id $job.Id | Wait-Job | Out-Null

        $results = $job | Receive-Job 

        foreach ($result in $results) {
            $result | Should -Be 'Succeeded'
        }
    
    }


}




