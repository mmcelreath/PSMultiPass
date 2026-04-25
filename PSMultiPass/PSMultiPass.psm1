# Implement your module commands in this script.
#Dot source private functions.
Get-ChildItem -Path $PSScriptRoot\Functions\Public\*.ps1 | ForEach-Object { . $_.FullName }

#Dot source public functions.
Get-ChildItem -Path $PSScriptRoot\Functions\Private\*.ps1 | ForEach-Object { . $_.FullName }

# Export only the functions using PowerShell standard verb-noun naming.
# Be sure to list each exported functions in the FunctionsToExport field of the module manifest file.
# This improves performance of command discovery in PowerShell.
Export-ModuleMember -Function *-*
