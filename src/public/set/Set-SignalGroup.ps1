<#
    .SYNOPSIS
        Updates the properties of an existing Signal group.

    .DESCRIPTION
        Modifies the properties of an existing Signal group by sending a PUT request
        to the Signal API. This function allows you to update various group metadata
        including the group name, description, message expiration settings, and group
        avatar image. Only the properties you specify will be updated; other properties
        remain unchanged. The authenticated user must have administrative privileges
        in the group to modify its properties.

    .PARAMETER GroupID
        The ID of the Signal group to update. This parameter is mandatory.

    .PARAMETER Name
        Optional new name for the Signal group. If specified, the group will be renamed
        to this value.

    .PARAMETER Description
        Optional new description for the Signal group. This text appears in group
        information and helps members understand the group's purpose.

    .PARAMETER ExpirationTime
        Optional message expiration time in seconds. When set, messages in the group
        will automatically disappear after this duration. Set to 0 to disable
        message expiration.

    .PARAMETER Path
        Optional path to an avatar image file for the group. Supported formats are
        JPG, PNG, and GIF with a maximum file size of 5 MB. The image will be
        converted to base64 and uploaded as the group avatar.

    .EXAMPLE
        Set-SignalGroup -GroupID "group123" -Name "Updated Group Name"
        
        Updates the name of the specified Signal group.

    .EXAMPLE
        Set-SignalGroup -GroupID "group123" -Name "My Group" -Description "A group for team discussions"
        
        Updates both the name and description of the Signal group.

    .EXAMPLE
        Set-SignalGroup -GroupID "group123" -ExpirationTime 3600
        
        Sets message expiration to 1 hour (3600 seconds) for the group.

    .EXAMPLE
        Set-SignalGroup -GroupID "group123" -Path "C:\Images\avatar.png"
        
        Updates the group avatar with the specified image file.

    .EXAMPLE
        Set-SignalGroup -GroupID "group123" -Name "New Name" -Description "New description" -ExpirationTime 86400 -Path "C:\avatar.jpg"
        
        Updates multiple group properties in a single operation.

    .NOTES
        Requires a configured Signal account via Set-SignalConfiguration.
        The authenticated user must have administrative privileges in the target group.
        Avatar images are automatically converted to base64 format for upload.
        Only specified parameters are updated; others remain unchanged.
        Message expiration time of 0 disables automatic message deletion.

    .LINK
        New-SignalGroup
        Get-SignalGroup
        Remove-SignalGroups
        Add-SignaMemberToGroup
#>
function Set-SignalGroup {
	param
	(
		[Parameter(Mandatory = $true)]
		[string]$GroupID,
		[string]$Name,
		[string]$Description,
		[int]$ExpirationTime,
		[string]$Path
	)
	
	$body = @{
	}
	
	if ($Name) {
		$body.add("name", $Name)
	}
	if ($Description) {
		$body.add("description", $Description)
	}
	if ($ExpirationTime) {
		$body.add("expiration_time", $ExpirationTime)
	}
	
	if ($Path) {
		$FullFilePath = resolve-path $path
		$Avatar = [Convert]::ToBase64String([IO.File]::ReadAllBytes($FullFilePath.path))
		$body.add("base64_avatar", $Avatar)
	}
	$Endpoint = "/v1/groups/{0}/{1}" -f $SignalConfig.RegistredNumber, $GroupID
	
	Invoke-SignalApiRequest -Method 'PUT' -Endpoint $Endpoint -Body $body
}