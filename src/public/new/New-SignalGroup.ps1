# Create a Signal group
<#
    .SYNOPSIS
        Creates a new Signal group.

    .DESCRIPTION
        Sends a POST request to '/v1/groups' to create the group with the given
        name, members and settings.

    .PARAMETER Name
        Name of the new group.

    .PARAMETER Members
        Array of phone numbers to add to the group.

    .PARAMETER Description
        Optional group description.

    .PARAMETER ExpirationTime
        Message expiration time in seconds. Use 0 to disable disappearing
        messages.
#>
function New-SignalGroup {
	param
	(
		[Parameter(Mandatory = $true)]
		[string]$Name,
		[string[]]$Members,
		[string]$Description,
		[int]$ExpirationTime = 0
	)
	
	$body = @{
		"description"	  = $Description
		"expiration_time" = $ExpirationTime
		"group_link"	  = "disabled"
		"members"		  = [array]$Members
		"name"		      = $Name
		"permissions"	  = @{
			"add_members" = "only-admins"
			"edit_group"  = "only-admins"
		}
	}

	$Endpoint = "/v1/groups/$($SignalConfig.RegistredNumber)"
	
	Invoke-SignalApiRequest -Method 'POST' -Endpoint $Endpoint -Body $body
}