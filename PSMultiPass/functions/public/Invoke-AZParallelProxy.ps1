<#
.SYNOPSIS
    Executes a script block in parallel across multiple Azure subscriptions.

.DESCRIPTION
    This function iterates through multiple Azure subscriptions in parallel, setting the
    Azure context for each subscription before executing the provided script block.
    It uses Invoke-ForEachParallelProxy internally to manage parallel execution.

.PARAMETER Subscriptions
    An array of subscription IDs or names to execute the script block against.
    The function will set the Azure context for each subscription before execution.

.PARAMETER ScriptBlock
    The script block to execute in each subscription context.
    The subscription name/ID is available as $_ within the script block.

.PARAMETER ThrottleLimit
    The maximum number of subscription contexts to process in parallel.
    Default value is 5. Increase to process more subscriptions simultaneously.

.EXAMPLE
    PS> $subs = @("prod-sub-1", "prod-sub-2", "dev-sub-1")
    PS> Invoke-AZParallelProxy -Subscriptions $subs -ScriptBlock {
    PS>     Get-AzVirtualMachine | Select-Object Name, ResourceGroupName
    PS> } -ThrottleLimit 3
    
    Lists all virtual machines across three subscriptions in parallel.

.NOTES
    Requires Azure PowerShell module (Az.Accounts) to be installed and authenticated.
    User variables are automatically imported into the parallel execution context.

.LINK
    Invoke-ForEachParallelProxy
    Set-AzContext
#>
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

