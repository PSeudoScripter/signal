<#
    .SYNOPSIS
        Updates the properties of an existing Signal group.

    .DESCRIPTION
        Sends a PUT request to '/v1/groups/<number>/<groupId>' to change
        group metadata such as name, description, avatar or expiration
        time.

    .PARAMETER GroupID
        Identifier of the group to update.

    .PARAMETER Name
        New name for the group.

    .PARAMETER Description
        New group description.

    .PARAMETER ExpirationTime
        New message expiration time in seconds.

    .PARAMETER Path
        Path to an avatar image (JPG, PNG or GIF, max 5 MB).

    .EXAMPLE
        PS C:\> Set-SignalGroup -GroupID $id -Name "New Name"
        Renames the group.
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