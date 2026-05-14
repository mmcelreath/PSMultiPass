<#
.SYNOPSIS
    Gets a list of default variables to exclude from parallel execution.

.DESCRIPTION
    This private function returns a collection of variable names that should be excluded
    when importing variables into parallel script blocks. It combines:
    - Default cmdlet binding parameters (like Verbose, Debug, etc.)
    - Current bound parameters
    - Standard user environment variables
    
.EXAMPLE
    PS> $excludeVars = func_GetDefaultExcludeVariables
    PS> $excludeVars | Select-Object -First 5
    
    Returns a list of variable names to exclude from parallel import.

.NOTES
    This is a private helper function used internally by Invoke-ForEachParallelProxy.
    It helps prevent conflicts and unnecessary variable passing in parallel execution contexts.

.LINK
    Invoke-ForEachParallelProxy
#>
function func_GetDefaultExcludeVariables {
    Function _temp {
        [cmdletbinding(SupportsShouldProcess=$True)] param() 
    }
        
    $VariablesToExclude = @( (Get-Command _temp | Select-Object -ExpandProperty parameters).Keys + $PSBoundParameters.Keys + $StandardUserEnv.Variables )
        
    Write-Output $VariablesToExclude

}