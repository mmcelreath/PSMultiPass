# Invoke-AZParallelProxy - Examples
Invokes a `scriptblock` against an array of Azure Subscriptions

This function will use the Invoke-ForEachParallelProxy command from this module to run the provided `scriptblock` in parallel under the context of each subscription. Use the `-ThrottleLimit` parameter to control how many parallel operations will run at the same time.

### Install the module

```powershell
Install-Module -Name PSMultiPass 
```

### Using the $context Variable
When this function runs, it will append the following Context ScriptBlock to the beginning of the ScriptBlock you provide. The Context ScriptBlock sets the AZContext to the current subscription in the process and stores it in a variable called `$context`

```powershell
$contextScriptBlock = {
    # Sets AZContext to the current subscription being processed
    $context = Set-AzContext -Subscription $_ -Scope Process
}
```

In your ScriptBlock, make sure to pass the `$context` variable to the `-AZContext` parameter in your AZ commands like this:

```powershell
$scriptblock = {
    Get-AzResourceGroup -Name 'RG-Name' -AzContext $context
}
```


### Example - Get Resource Groups whose name starts with "RG-"

```powershell
$subscriptions = @('Subscription1', 'Subscription2')                     

Invoke-AZParallelProxy -Subscriptions $subscriptions -ScriptBlock {
    
    $rg = Get-AzResourceGroup -Name 'RG-*' -AzContext $context

    Write-Host $rg.ResourceGroupName
}

Output
------
RG-Subscription1
RG-Subscription2

```

### Example - Using a ThreadSafe variable to collect output from each parallel process

```powershell
$subscriptions = @('Subscription1', 'Subscription2')                     

$Bag = [System.Collections.Concurrent.ConcurrentBag[psobject]]::new()

Invoke-AZParallelProxy -Subscriptions $subscriptions -ScriptBlock {
    $rg = Get-AzResourceGroup -Name 'RG-*' -AzContext $context

    $Bag.Add($rg)
}

$results = $Bag.ToArray()
$results | ft


ResourceGroupName Location ProvisioningState Tags TagsTable ResourceId                                                                        ManagedBy
----------------- -------- ----------------- ---- --------- ----------                                                                        ---------
RG-Subscription1  eastus2  Succeeded                        /subscriptions/{Subscription1-ID}/resourceGroups/RG-Subscription1
RG-Subscription2  eastus2  Succeeded                        /subscriptions/{Subscription2-ID}/resourceGroups/RG-Subscription2 

```

