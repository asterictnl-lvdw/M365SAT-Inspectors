# Date: 25-1-2023
# Version: 1.0
# Benchmark: CIS Azure v3.0.0
# Product Family: Microsoft Azure
# Purpose: Ensure That Private Endpoints Are Used Where Possible (Automated)
# Author: Leonardo van de Weteringh

# New Error Handler Will be Called here
Import-Module PoShLog

#Call the OutPath Variable here
$path = @($OutPath)


function Build-CISAz542($findings)
{
	#Actual Inspector Object that will be returned. All object values are required to be filled in.
	$inspectorobject = New-Object PSObject -Property @{
		ID			     = "CISAz542"
		FindingName	     = "CIS Az 5.4.2 - Private Endpoints Are Not Used Where Possible with Cosmos DBs"
		ProductFamily    = "Microsoft Azure"
		RiskScore	     = "2"
		Description	     = "For sensitive data, private endpoints allow granular control of which services can communicate with Cosmos DB and ensure that this network traffic is private. You set this up on a case by case basis for each service you wish to be connected."
		Remediation	     = "Use the PowerShell Script to remediate the issue."
		PowerShellScript = 'Update-AzMySqlServer -ResourceGroupName <server>.ResourceGroupName -Name <Server>.Name -ssl-enforcement Enabled'
		DefaultValue	 = "By default Cosmos DB does not have private endpoints enabled and its traffic is public to the network."
		ExpectedValue    = "Enabled"
		ReturnedValue    = "$findings"
		Impact		     = "2"
		Likelihood	     = "1"
		RiskRating	     = "Low"
		Priority		 = "Low"
		References	     = @(@{ 'Name' = 'Configure Azure Private Link for an Azure Cosmos DB account'; 'URL' = 'https://learn.microsoft.com/en-us/azure/cosmos-db/how-to-configure-private-endpoints?tabs=arm-bicep' },
		@{ 'Name' = 'Configure access to Azure Cosmos DB from virtual networks (VNet)'; 'URL' = 'https://learn.microsoft.com/en-us/azure/cosmos-db/how-to-configure-vnet-service-endpoint' },
		@{ 'Name' = 'NS-2: Secure cloud native services with network controls'; 'URL' = 'https://learn.microsoft.com/en-us/security/benchmark/azure/mcsb-network-security#ns-2-secure-cloud-native-services-with-network-controls' })
	}
	return $inspectorobject
}

function Audit-CISAz542
{
	try
	{
		$violation = @()
		$ResourceGroupNames = Get-AzResource | Select-Object ResourceGroupName -Unique
		foreach ($ResourceGroupName in $ResourceGroupNames){
			$AzCosmosDBAccounts = Get-AzCosmosDBAccount -ResourceGroupName $ResourceGroupName.ResourceGroupName
			foreach ($AzCosmosDBAccount in $AzCosmosDBAccounts){
				$Account = Get-AzCosmosDBAccount -ResourceGroupName $ResourceGroupName.ResourceGroupName -Name $AzCosmosDBAccount.Name
				if ($Account.PrivateEndpointConnections.PrivateLinkServiceConnectionState.Status -ne 'Approved'){
					$violation += $CosmosDBDatabase.Name
				}
			}
		}

		if ($violation.count -igt 0){
			$finalobject = Build-CISAz542($violation)
			return $finalobject
		}
		return $null
	}
	catch
	{
		Write-WarningLog 'The Inspector: {inspector} was terminated!' -PropertyValues $_.InvocationInfo.ScriptName
		Write-ErrorLog 'An error occured on line {line} char {char} : {error}' -ErrorRecord $_ -PropertyValues $_.InvocationInfo.ScriptLineNumber, $_.InvocationInfo.OffsetInLine, $_.InvocationInfo.Line
	}
}
return Audit-CISAz542