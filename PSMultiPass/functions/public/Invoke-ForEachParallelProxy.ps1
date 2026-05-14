<#
.SYNOPSIS
    Executes a script block in parallel across multiple input objects with variable management.

.DESCRIPTION
    This function wraps ForEach-Object -Parallel to provide enhanced variable importing capabilities
    and easier parallel execution management. It allows selective importing of user variables into
    the parallel context while excluding system and cmdlet-binding variables.
    
    The input object is available as $_ within the script block, and parallel execution is
    controlled via ThrottleLimit, TimeoutSeconds, and optional job execution.

.PARAMETER InputObject
    The object(s) to iterate through in parallel. Accepts arrays or pipeline input.

.PARAMETER ScriptBlock
    The script block to execute for each input object. The current object is available as $_.

.PARAMETER ThrottleLimit
    The maximum number of parallel threads to execute simultaneously.
    Default value is 5. Increase for more parallelism on systems with more cores.

.PARAMETER ImportUserVariables
    Switch to enable importing current session variables into the parallel execution context.
    By default, only necessary variables are imported to minimize context overhead.

.PARAMETER IncludeUserVariableName
    Specify an array of variable names to include when ImportUserVariables is enabled.
    If specified, only these variables will be imported (whitelist mode).

.PARAMETER ExcludeUserVariableName
    Specify an array of variable names to exclude from import when ImportUserVariables is enabled.
    Works in conjunction with default exclusions (blacklist mode).

.PARAMETER TimeoutSeconds
    The timeout in seconds for each parallel operation. Default 0 (no timeout).
    Ignored if AsJob is specified.

.PARAMETER AsJob
    Switch to return the operation as a background job instead of waiting for completion.

.PARAMETER UseNewRunspace
    Switch to use a new runspace for each parallel iteration.

.PARAMETER Confirm
    Switch to prompt for confirmation before executing the parallel operation.

.EXAMPLE
    PS> 1..10 | Invoke-ForEachParallelProxy -ScriptBlock { $_ * 2 } -ThrottleLimit 5
    
    Multiplies numbers 1-10 by 2 in parallel with 5 concurrent threads.

.EXAMPLE
    PS> $data = @("file1.txt", "file2.txt", "file3.txt")
    PS> $data | Invoke-ForEachParallelProxy -ScriptBlock {
    PS>     Get-Content $_ | Measure-Object -Line
    PS> } -ImportUserVariables
    
    Processes multiple files in parallel with access to current session variables.

.NOTES
    Variables are imported intelligently, excluding system variables and cmdlet-binding parameters
    to reduce context overhead. Use IncludeUserVariableName or ExcludeUserVariableName to fine-tune
    which variables are passed to parallel contexts.

.LINK
    ForEach-Object
    Invoke-AZParallelProxy
    func_GetDefaultExcludeVariables
#>
function Invoke-ForEachParallelProxy {
   [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [PSObject]$InputObject,
    
        [Parameter(Mandatory = $true)]
        [ScriptBlock]$ScriptBlock,

        [Parameter(Mandatory = $false)]
        [Int]$ThrottleLimit = 5,

        [Parameter(Mandatory = $false)]
        [Switch]$ImportUserVariables,

        [Parameter(Mandatory = $false)]
        [string[]]
        $IncludeUserVariableName,

        [Parameter(Mandatory = $false)]
        [string[]]
        $ExcludeUserVariableName,

        [Parameter(Mandatory = $false)]
        [int]$TimeoutSeconds = 0,

        [Parameter(Mandatory = $false)]
        [Switch]$AsJob,

        [Parameter(Mandatory = $false)]
        [Switch]$UseNewRunspace,

        [Parameter(Mandatory = $false)]
        [Switch]$Confirm
    )

    $combinedScriptBlockString = ''

    # Get User Variables to Import into Parallel scriptblock
    if ($ImportUserVariables) {
        if ($IncludeUserVariableName) {
            $UserVariables = Get-Variable | where-object { $IncludeUserVariableName -contains $_.Name }
            Write-Verbose "Including variables $( ($IncludeUserVariableName | Sort-Object ) -join ", ")`n"
        } else {

            $VariablesToExclude =  func_GetDefaultExcludeVariables

            # Get Excluded variable names from parameter and add to $VariablesToExclude
            $VariablesToExclude += $ExcludeUserVariableName

            Write-Verbose "Excluding variables $( ($VariablesToExclude | Sort-Object ) -join ", ")`n"

            $UserVariables = @( Get-Variable | Where-Object { -not ($VariablesToExclude -contains $_.Name) } )
            Write-Verbose "Found variables to import: $( ($UserVariables | Select-Object -expandproperty Name | Sort-Object ) -join ", " | Out-String).`n"
        }
    
        $ImportedVariablesScriptBlock = {
            $vars = $Using:UserVariables
            
            $vars | ForEach-Object {
                $Variable = $_

                $varcheck = Get-Variable | where-object { $_.Name -eq $Variable.Name }
                
                if ($varcheck) {
                    Write-Verbose "Variable $($Variable.Name) already exists   with value $($varcheck.Value) and will be skipped."
                } else {
                    Write-Verbose "Importing variable $($Variable.Name) with value $($Variable.Value)"
                    Set-Variable -Name $Variable.Name -Value $Variable.Value -Scope Global
                }
            }
        }

        $combinedScriptBlockString += $ImportedVariablesScriptBlock.ToString() + "`n"
    }

    $combinedScriptBlockString += $ScriptBlock.ToString() + "`n"

    $scriptBlockCombined = [scriptblock]::Create($combinedScriptBlockString)

    $params = @{
        Parallel = $scriptBlockCombined
        ThrottleLimit = $ThrottleLimit
        UseNewRunspace = $UseNewRunspace
        Confirm = $Confirm
    }

    if ($AsJob -eq $true) {
        $params.Add('AsJob', $AsJob)
    } else {
        $params.Add('TimeoutSeconds',  $TimeoutSeconds)
    }
        
    $InputObject | ForEach-Object @params
    
}