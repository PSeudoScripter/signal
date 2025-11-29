<#
    .SYNOPSIS
        Sends a text message and/or attachment via Signal to one or more recipients.

    .DESCRIPTION
        Sends messages through the Signal messaging service to specified recipients using the
        Signal REST API. The function supports sending text messages, file attachments, or both.
        Recipients can be individual phone numbers or Signal group IDs. File attachments are
        automatically encoded to base64 and their MIME type is determined based on the file extension.
        
        The function requires a valid Signal configuration to be set up and uses the registered
        phone number from the configuration to send messages.

    .PARAMETER Recipients
        An array of phone numbers (in international format) or Signal group IDs to send the
        message to. Phone numbers should include the country code (e.g., "+1234567890").

    .PARAMETER Message
        The text message content to send. This parameter is optional, but either Message or
        Path (or both) must be specified.

    .PARAMETER Path
        The file path to an attachment to send along with the message. The file must exist
        and will be automatically encoded to base64. Supports images, videos, documents and
        text files. This parameter is optional, but either Message or Path (or both) must
        be specified.

    .EXAMPLE
        Send-SignalMessage -Recipients "+1234567890" -Message "Hello from PowerShell!"
        
        Sends a simple text message to a single recipient.

    .EXAMPLE
        Send-SignalMessage -Recipients @("+1234567890", "+0987654321") -Message "Group message"
        
        Sends a text message to multiple recipients.

    .EXAMPLE
        Send-SignalMessage -Recipients "+1234567890" -Path "C:\Documents\report.pdf"
        
        Sends a file attachment without a text message.

    .EXAMPLE
        Send-SignalMessage -Recipients "+1234567890" -Message "Here's the report" -Path "C:\Documents\report.pdf"
        
        Sends both a text message and a file attachment.

    .EXAMPLE
        $groupId = "group.12345abcdef"
        Send-SignalMessage -Recipients $groupId -Message "Hello group!"
        
        Sends a message to a Signal group using the group ID.

    .OUTPUTS
        System.Object
        Returns the response from the Signal API indicating the success or failure of the message delivery.

    .NOTES
        - Requires a valid Signal configuration to be set up using New-SignalConfiguration.
        - The registered phone number from the configuration is used as the sender.
        - File attachments are automatically converted to base64 encoding.
        - MIME types are determined automatically based on file extensions.
        - Supported file types include images, videos, documents, and text files.
        - Either Message or Path (or both) parameters must be provided.

    .LINK
        New-SignalConfiguration
        Get-SignalConfiguration
        Receive-SignalMessage
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
