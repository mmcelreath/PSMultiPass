# Invoke-ForEachParallelProxy - Examples


### Install the module

```powershell
Install-Module -Name PSMultiPass 
```

### Example - Run a scriptblock 5 times, importing the User's current variables using `-ImportUserVariables`

```powershell
$Variable1 = 'Value-1'
$Variable2 = 'Value-2'

Invoke-ForEachParallelProxy -InputObject (1..5) -ScriptBlock {
    
    Write-Host "Processing item $_ : Variable1=$Variable1, Variable2=$Variable2"

} -ImportUserVariables 

Processing item 2 : Variable1=Value-1, Variable2=Value-2
Processing item 5 : Variable1=Value-1, Variable2=Value-2
Processing item 1 : Variable1=Value-1, Variable2=Value-2
Processing item 3 : Variable1=Value-1, Variable2=Value-2
Processing item 4 : Variable1=Value-1, Variable2=Value-2
```

### Example - Run a scriptblock 5 times, using `-ImportUserVariables` and `-IncludeUserVariableName` to only import the variable named `Variable2`

```powershell
$Variable1 = 'Value-1'
$Variable2 = 'Value-2'

Invoke-ForEachParallelProxy -InputObject (1..5) -ScriptBlock {
    
    Write-Host "Processing item $_ : Variable1=$Variable1, Variable2=$Variable2"

} -ImportUserVariables -IncludeUserVariableName Variable2

Processing item 1 : Variable1=, Variable2=Value-2
Processing item 2 : Variable1=, Variable2=Value-2
Processing item 3 : Variable1=, Variable2=Value-2
Processing item 4 : Variable1=, Variable2=Value-2
Processing item 5 : Variable1=, Variable2=Value-2
```

### Example - Using a ThreadSafe variable to collect output from each parallel process

```powershell

$Variable1 = 'Value-1'
$Variable2 = 'Value-2'

$Bag = [System.Collections.Concurrent.ConcurrentBag[psobject]]::new()

Invoke-ForEachParallelProxy -InputObject (1..5) -ScriptBlock {
    
    $object = [PSCustomObject]@{
        Item = $_
        Variable1 = $Variable1
        Variable2 = $Variable2
    }
    
    $Bag.Add($object)

} -ImportUserVariables 

$results = $Bag.ToArray()
$results

Item Variable1 Variable2
---- --------- ---------
   5 Value-1   Value-2
   4 Value-1   Value-2
   2 Value-1   Value-2
   1 Value-1   Value-2
   3 Value-1   Value-2

```
