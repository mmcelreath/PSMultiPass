$ModuleName = 'PSMultiPass'
$ModuleManifestName = "$ModuleName.psd1"
$ModuleManifestPath = "$PSScriptRoot\PSMultiPass\$ModuleManifestName"

$ModuleManifestPath

Test-ModuleManifest -Path $ModuleManifestPath





$sb1 = {
    Write-Host "ScriptBlock 1" -ForegroundColor Green
}

$sb2 = {
    Write-Host "ScriptBlock 2" -ForegroundColor Magenta
}

$sbCombined = {
    & $sb1
}

(1..1) | ForEach-Object -Parallel $combined



$sb1 = { Write-Host "Hello" }
$sb2 = { Write-Host "World" }

# Combine by nesting
$combined = { & $sb1; & $sb2 }

# Execute
& $combined