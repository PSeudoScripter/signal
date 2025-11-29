<#
    .SYNOPSIS
        Creates a new Signal group with specified members and settings.

    .DESCRIPTION
        Creates a new Signal group. This function allows you to create a group with 
		a custom name, description, initial members, and message expiration settings. 
		The group is created with administrative permissions restricted to admins only, 
		and group links are disabled by default for security. The creator automatically 
		becomes a group administrator with full management privileges.

    .PARAMETER Name
        The name of the new Signal group. This parameter is mandatory and will be
        displayed as the group title to all members.

    .PARAMETER Members
        Optional array of phone numbers (with country codes) to add as initial group
        members. Phone numbers should be in international format (e.g., "+1234567890").
        If not specified, the group will be created with only the creator as a member.

    .PARAMETER Description
        Optional description for the Signal group. This text appears in group
        information and helps members understand the group's purpose or rules.

    .PARAMETER ExpirationTime
        Optional message expiration time in seconds. When set to a value greater than 0,
        messages in the group will automatically disappear after this duration.
        Default value is 0, which disables disappearing messages.

    .EXAMPLE
        New-SignalGroup -Name "Family Chat"
        
        Creates a new Signal group called "Family Chat" with only the creator as a member.

    .EXAMPLE
        New-SignalGroup -Name "Work Team" -Members @("+1234567890", "+0987654321")
        
        Creates a group called "Work Team" and adds two initial members.

    .EXAMPLE
        New-SignalGroup -Name "Project Alpha" -Description "Discussion for Project Alpha tasks" -Members @("+1111111111", "+2222222222")
        
        Creates a group with a name, description, and initial members.

    .EXAMPLE
        New-SignalGroup -Name "Secure Chat" -ExpirationTime 3600 -Members @("+1234567890")
        
        Creates a group with 1-hour message expiration (messages disappear after 3600 seconds).

    .OUTPUTS
        System.Object
        Returns the newly created group information including group ID, name, and other
        group metadata that can be used for subsequent group management operations.

    .NOTES
        Requires a configured Signal account via Set-SignalConfiguration.
        The creator automatically becomes a group administrator.
        Group permissions are set to admin-only for adding members and editing group settings.
        Group links are disabled by default for security purposes.
        Phone numbers must include country codes and be properly formatted.
        Message expiration applies to all future messages sent to the group.

    .LINK
        Get-SignalGroup
        Set-SignalGroup
        Join-SignalGroup
        Add-SignaMemberToGroup
        Remove-SignalGroups
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