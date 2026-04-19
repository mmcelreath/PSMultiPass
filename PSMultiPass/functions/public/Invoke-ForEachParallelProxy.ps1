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
        $SkipUserVariableName,

        [Parameter(Mandatory = $false)]
        [string[]]
        $IncludeUserVariableName,

        [Parameter(Mandatory = $false)]
        [string[]]
        $ExcludeUserVariableName,

        [Parameter(Mandatory = $false)]
        [int]$TimeoutSeconds,

        [Parameter(Mandatory = $false)]
        [Switch]$AsJob,

        [Parameter(Mandatory = $false)]
        [Switch]$UseNewRunspace,

        [Parameter(Mandatory = $false)]
        [Switch]$Confirm
    )

    # Get User Variables to Import into Parallel scriptblock

    if ($IncludeUserVariableName) {
        $UserVariables = Get-Variable | where-object { $IncludeUserVariableName -contains $_.Name }
        Write-Verbose "Including variables $( ($IncludeUserVariableName | Sort-Object ) -join ", ")`n"
    } else {
        Function _temp {[cmdletbinding(SupportsShouldProcess=$True)] param() }
        $VariablesToExclude = @( (Get-Command _temp | Select-Object -ExpandProperty parameters).Keys + $PSBoundParameters.Keys + $StandardUserEnv.Variables )
        
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

    $combinedScriptBlockString = ''

    if ($ImportUserVariables) {
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