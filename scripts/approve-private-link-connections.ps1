# Copyright (c) Microsoft Corporation.
# Licensed under the MIT license.

# Define script arguments
[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)] [String] $ResourceId
)

# Get Private Link Endpoint Connection
Write-Output "Getting Private Link Endpoint Connection"
$privateEndpoints = Get-AzPrivateEndpointConnection -PrivateLinkResourceId $ResourceId
$privateEndpoints

# Approve all Private Endpoint Connection
Write-Output "Approving all Private Link Endpoint Connections"
foreach ($privateEndpoint in $privateEndpoints) {
	Write-Output $privateEndpoint.PrivateLinkServiceConnectionState.Status
	if ($privateEndpoint.PrivateLinkServiceConnectionState.Status -eq 'Pending') {
		$id = $privateEndpoint.id
		Approve-AzPrivateEndpointConnection -ResourceId "${id}"
	}
}