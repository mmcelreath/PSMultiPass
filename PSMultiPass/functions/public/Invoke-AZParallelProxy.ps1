function Invoke-AZParallelProxy {
   [CmdletBinding()]
    param (

        [Parameter(Mandatory = $true)]
        [string[]]$Subscriptions,

        [Parameter(Mandatory = $true)]
        [ScriptBlock]$ScriptBlock
        
    )
    
    $combinedScriptBlockString = ''

    $contextScriptBlockString = {
        Write-Verbose "Processing subscription: $_"
        $context = Set-AzContext -Subscription $_ -Scope Process
    }

    $combinedScriptBlockString += $contextScriptBlockString.ToString() + "`n"

    $combinedScriptBlockString = $ScriptBlock.ToString()

    $scriptBlockCombined = [scriptblock]::Create($combinedScriptBlockString)

    Invoke-ForEachParallelProxy -InputObject $Subscriptions -ScriptBlock $scriptBlockCombined -ImportUserVariables
    
}

Invoke-AZParallelProxy -Subscriptions $subs -ScriptBlock {
    Get-AzResourceGroup -Name Subscription-* -AzContext $context
}