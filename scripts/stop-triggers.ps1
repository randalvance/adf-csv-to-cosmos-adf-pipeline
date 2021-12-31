param
(
	[parameter(Mandatory = $false)] [String] $DataFactoryName,
    [parameter(Mandatory = $false)] [String] $ResourceGroupName,
    [parameter(Mandatory = $false)] [String] $ArmTemplate
)

$templateJson = Get-Content $ArmTemplate | ConvertFrom-Json
$resources = $templateJson.resources
$triggersInTemplate = $resources | Where-Object { $_.type -eq "Microsoft.DataFactory/factories/triggers" }
$triggerNamesInTemplate = $triggersInTemplate | ForEach-Object {$_.name.Substring(37, $_.name.Length-40)}
	
$triggersDeployed = Get-AzDataFactoryV2Trigger -DataFactoryName $DataFactoryName -ResourceGroupName $ResourceGroupName
	
$triggersToStop = $triggersDeployed | Where-Object { $triggerNamesInTemplate -contains $_.Name } | ForEach-Object { 
    New-Object PSObject -Property @{
        Name = $_.Name
        TriggerType = $_.Properties.GetType().Name 
    }
}

#Stop all triggers
Write-Host "Stopping deployed triggers`n"
$triggersToStop | ForEach-Object {
    if ($_.TriggerType -eq "BlobEventsTrigger") {
        Write-Host "Unsubscribing" $_.Name "from events"
        $status = Remove-AzDataFactoryV2TriggerSubscription -ResourceGroupName $ResourceGroupName -DataFactoryName $DataFactoryName -Name $_.Name
        while ($status.Status -ne "Disabled"){
            Start-Sleep -s 5
            $status = Get-AzDataFactoryV2TriggerSubscriptionStatus -ResourceGroupName $ResourceGroupName -DataFactoryName $DataFactoryName -Name $_.Name
        }
    }
    Write-Host "Stopping trigger" $_.Name
    Stop-AzDataFactoryV2Trigger -ResourceGroupName $ResourceGroupName -DataFactoryName $DataFactoryName -Name $_.Name -Force
    Write-Host "Stopped trigger" $_.Name ". Now sleeping for 5 seconds"
    Start-Sleep -s 5
}
	