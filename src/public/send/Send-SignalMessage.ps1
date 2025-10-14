# Send message
<#
	.SYNOPSIS
	    Sends a text or attachment to one or more recipients.

	.DESCRIPTION
	    Calls '/v2/send' on the Signal REST API to deliver a message to phone
	    numbers or groups. Attachments are automatically converted to base64.

	.PARAMETER Recipients
	    One or more phone numbers or group IDs to send to.

	.PARAMETER Message
	    Optional text message body.

	.PARAMETER Path
	    Optional path to a file that will be sent as an attachment.
#>
function Send-SignalMessage {
	param
	(
		[Parameter(Mandatory = $true)]
		[string[]]$Recipients,
		[Parameter(Mandatory = $false)]
		[string]$Message,
		[ValidateScript({test-path $_})]
		[string]$Path
	)
	
	$body = @{
		number	   = $SignalConfig.RegistredNumber
		recipients = $Recipients
	}
	if ($Message) {
		$body.add("message", $Message)
		$body.Add("text_mode", 'normal')
		
	}
	
	if ($Path) {
		$FullFilePath = resolve-path $Path
		$FileName = ($FullFilePath.path -split "\\")[-1]
		$FileExt = ($FileName -split ".")[-1]
		$mimetype = "application/$fileExt"
		if ($ImageExtensions.contains($FileExt.ToLower())) { $mimetype = "image/$fileExt" }
		if ($TextExtensions.contains($FileExt.ToLower())) { $mimetype = "text/$fileExt" }
		if ($VideoExtensions.contains($FileExt.ToLower())) { $mimetype = "video/$fileExt" }
		
		$base64string = [Convert]::ToBase64String([IO.File]::ReadAllBytes($FullFilePath.path))
		$Base64DataStream = "data:$mimetype;filename=$FileName;base64,$base64string"
		$body.add("base64_attachments", @($Base64DataStream))
	}
	Invoke-SignalApiRequest -Method 'POST' -Endpoint '/v2/send' -Body $body
}
