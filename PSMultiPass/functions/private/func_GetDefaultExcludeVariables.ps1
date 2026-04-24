function func_GetDefaultExcludeVariables {
    Function _temp {
        [cmdletbinding(SupportsShouldProcess=$True)] param() 
    }
        
    $VariablesToExclude = @( (Get-Command _temp | Select-Object -ExpandProperty parameters).Keys + $PSBoundParameters.Keys + $StandardUserEnv.Variables )
        
    Write-Output $VariablesToExclude

}