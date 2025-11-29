# Helper function for sending HTTP requests
<#
	.SYNOPSIS
	    Sends an HTTP request to the configured Signal REST API.

	.DESCRIPTION
	    Wraps Invoke-RestMethod and automatically converts the body to JSON. The
	    function is used internally by all other cmdlets.

	.PARAMETER Method
	    HTTP method such as GET, POST, PUT or DELETE.

	.PARAMETER Endpoint
	    API endpoint path beginning with '/'.

	.PARAMETER Headers
	    Optional hashtable of additional HTTP headers.

	.PARAMETER Body
	    Hashtable representing the JSON body to send.

	.EXAMPLE
	    PS C:\> Invoke-SignalApiRequest -Method 'GET' -Endpoint '/v1/accounts'
#>
function Invoke-SignalApiRequest {
	[CmdletBinding(ConfirmImpact = 'None',
				PositionalBinding = $false,
				SupportsPaging = $false,
				SupportsShouldProcess = $false)]
	param
	(
		[Parameter(Mandatory = $true)]
		[string]$Method = 'GET',
		[Parameter(Mandatory = $true)]
		[string]$Endpoint,
		[hashtable]$Headers = $null,
		[hashtable]$Body = $null
	)
	
	if (! $SignalConfig.ServerURL) {
		write-error "Signal is not configured. Run Get-SignalConfiguration to find out more."
		return
	}
	
	$uri = "{0}{1}" -f $SignalConfig.ServerURL, $Endpoint
	
	$Parameters = @{
		"StatusCodeVariable" = "StatusCode";
		"Method"			 = $Method;
		"Uri"			     = $uri;
		"ContentType"	     = 'application/json'
	}
	
	if ($Body) {
		$Parameters.add("Body", ($Body | ConvertTo-Json -Compress -Depth 10))
	}
	if ($Headers) {
		$Parameters.Add("Headers", $Headers)
	}
	
	write-verbose ($Parameters | ConvertTo-Json -Depth 10)
	
	try {
		$response = Invoke-RestMethod @Parameters
	} catch {
		$StatusCode = $_.Exception.Message.split(": ")[1].trim()
		$SignalMessage = $_.ErrorDetails.Message #| convertfrom-json
		write-error "HTTP: $StatusCode"
		write-error $SignalMessage.error
		return
	}
	
	write-verbose "HTTP: $StatusCode"
	return $response
}
