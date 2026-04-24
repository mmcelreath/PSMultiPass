BeforeAll {
    Import-Module 'C:\code\Github\PSMultiPass\PSMultiPass\PSMultiPass.psm1' -Force
}

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
        Import-Module 'C:\code\Github\PSMultiPass\PSMultiPass\PSMultiPass.psm1' -Force
    }
    
    It 'Passes Invoke ForEach Parallel' {
        $throttleLimit = 25
        Invoke-ForEachParallelProxy -InputObject (1..100) -ScriptBlock {
            "Testing..." | Out-Null
        } -ThrottleLimit $throttleLimit
    }
    
    It 'Passes Invoke ForEach Parallel with User Variables' {
        $throttleLimit = 25
        Invoke-ForEachParallelProxy -InputObject (1..100) -ScriptBlock {
            "Testing..." | Out-Null
        } -ImportUserVariables -ThrottleLimit $throttleLimit
    }

    It 'Passes Invoke ForEach Parallel with User Variables As a Job' {
        $throttleLimit = 20

        $job = Invoke-ForEachParallelProxy -InputObject (1..20) -ScriptBlock {
            Write-Output 'Succeeded'
        } -ImportUserVariables -ThrottleLimit $throttleLimit -AsJob

        Get-Job -Id $job.Id | Wait-Job | Out-Null

        $results = $job | Receive-Job 

        foreach ($result in $results) {
            $result | Should -Be 'Succeeded'
        }
    
    }


}




