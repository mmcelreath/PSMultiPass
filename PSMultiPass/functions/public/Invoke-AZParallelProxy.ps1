function Invoke-AZParallelProxy {
   [CmdletBinding()]
    param (

        [Parameter(Mandatory = $true)]
        [string[]]$Subscriptions,

        [Parameter(Mandatory = $true)]
        [ScriptBlock]$ScriptBlock,

        [Parameter(Mandatory = $false)]
        [Int]$ThrottleLimit = 5
        
    )
    
    $combinedScriptBlockString = ''

    $contextScriptBlock = {
        Write-Verbose "Processing subscription: $_" -Verbose
        $context = Set-AzContext -Subscription $_ -Scope Process

    }

    $combinedScriptBlockString += $contextScriptBlock.ToString() + "`n"

    $combinedScriptBlockString += $ScriptBlock.ToString()

    $scriptBlockCombined = [scriptblock]::Create($combinedScriptBlockString)

    $params = @{
        InputObject = $Subscriptions
        ScriptBlock = $scriptBlockCombined
        ThrottleLimit = $ThrottleLimit
        ImportUserVariables = $true
    }
    
    Invoke-ForEachParallelProxy @params
    
}

