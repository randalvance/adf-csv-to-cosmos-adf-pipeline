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
	if ($privateEndpoint.PrivateLinkServiceConnectionState.Status -eq 'Pending') {
		$id = $privateEndpoint.id
		Approve-AzPrivateEndpointConnection -ResourceId "${id}"
	}
}