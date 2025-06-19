# Signal.psm1

# Documentation for signal cli REST API
# https://bbernhard.github.io/signal-cli-rest-api/
#
# Docker image from bbernhard
# bbernhard/signal-cli-rest-api:latest
#
# Git repository from bbernhard
# https://github.com/bbernhard/signal-cli-rest-api

# Path for configuration files
if ($IsWindows) {
	$SignalConfigFile = [System.IO.FileInfo]::new((Join-Path $env:LOCALAPPDATA "Signal Module" "SignalConfig.xml"))
}elseif ($isLinux -or $IsMacOS) {
	$SignalConfigFile = [System.IO.FileInfo]::new((Join-Path $HOME ".signalmodule" "SignalConfig.xml"))
} else {
	Write-Host "is Windows: $isWindows"
	Write-Host "is Linux: $isLinux"
	Write-Host "is MacOS: $IsMacOS"
	Write-Error "Not supported operating system"
	exit(3)
}

#region SignalConfiguration function

<#
.SYNOPSIS
    Creates or overwrites the Signal module configuration file.

.DESCRIPTION
    Stores the REST API URL and the registered sender number in an XML file that
    is loaded automatically by the module.

.PARAMETER SenderNumber
    Phone number in E.164 format used as sender.

.PARAMETER SignalServerURL
    URL of the signal-cli REST API instance, e.g. http://localhost:8080

.EXAMPLE
    PS C:\> New-SignalConfiguration -SenderNumber '+491234567890' -SignalServerURL 'http://localhost:8080'
    Creates the configuration file for the module.
#>
function New-SignalConfiguration {
	param
	(
		[Parameter(Mandatory = $true)]
		[ValidatePattern('\+[1-9]{1}[0-9]{9,12}')]
		[string]$SenderNumber,
		[Parameter(Mandatory = $true)]
		[string]$SignalServerURL
	)
	
	$SignalConfig = [pscustomobject]@{
		"ServerURL"	      = $SignalServerURL;
		"RegistredNumber" = $SenderNumber
	}
	Export-Clixml -Path $SignalConfigFile.Fullname -InputObject $SignalConfig -Force -NoClobber
	Import-Module $PSCommandPath -force -DisableNameChecking
}

<#
.SYNOPSIS
    Returns the current Signal module configuration.

.DESCRIPTION
    Reads the configuration XML file and returns its contents. When no
    configuration exists, a warning is shown unless -Quiet is used.

.PARAMETER Quiet
    Suppresses warnings when the configuration file is missing.
#>

function Get-SignalConfiguration {
	[CmdletBinding(PositionalBinding = $false,
				SupportsPaging = $false,
				SupportsShouldProcess = $false)]
	[OutputType([object])]
	param
	(
		[switch]$Quiet
	)
	
	if (Test-Path $SignalConfigFile.Fullname) {
		return import-clixml -Path $SignalConfigFile.Fullname -ErrorAction Stop
	}
	if (!$Quiet.IsPresent) {
		Write-Warning "No configuration file found. Path: $($SignalConfigFile.Fullname)"
		Write-Warning "Run New-SignalConfiguration -SenderNumber +491223345 -SignalServerURL 'http://mysignaldocker.local:8080'"
	}
}

if (!(Test-Path $SignalConfigFile.Fullname)) {
	Write-Warning "Signal is not configured. Run Get-SignalConfiguration to find out more."
}

if (!(Test-Path $SignalConfigFile.DirectoryName)) {
	New-Item -Path $SignalConfigFile.DirectoryName -ItemType Directory -Force
}
#endregion

$SignalConfig = Get-signalConfiguration -Quiet

$ImageExtensions = @('aces', 'apng', 'avci', 'avcs', 'avif', 'bmp', 'cgm', 'dpx', 'emf', 'example', 'fits', 'g3fax', 'gif', 'heic', 'heif', 'hej2k', 'ief', 'j2c', 'jaii', 'jais', 'jls', 'jp2', 'jpg','jpeg', 'jph', 'jphc', 'jpm', 'jpx', 'jxl', 'jxr', 'jxrA', 'jxrS', 'jxs', 'jxsc', 'jxsi', 'jxss', 'ktx', 'ktx2', 'naplps', 'png', 'svg+xml', 't38', 'tiff', 'tiff-fx', 'webp', 'wmf')
$TextExtensions = @('cache-manifest', 'calendar', 'cql', 'cql-expression', 'cql-identifier', 'css', 'csv', 'csv-schema', 'dns', 'encaprtp', 'enriched', 'example', 'fhirpath', 'flexfec', 'fwdred', 'gff3', 'grammar-ref-list', 'hl7v2', 'html', 'javascript', 'jcr-cnd', 'markdown', 'mizar', 'n3', 'parameters', 'parityfec', 'plain', 'provenance-notation', 'raptorfec', 'RED', 'rfc822-headers', 'richtext', 'rtf', 'rtp-enc-aescm128', 'rtploopback', 'rtx', 'SGML', 'shaclc', 'shex', 'spdx', 'strings', 't140', 'tab-separated-values', 'troff', 'turtle', 'ulpfec', 'uri-list', 'vcard', 'vtt', 'wgsl', 'xml', 'xml-external-parsed-entity')
$VideoExtensions = @('3gpp', '3gpp2', '3gpp-tt', 'AV1', 'BMPEG', 'BT656', 'CelB', 'DV', 'encaprtp', 'evc', 'example', 'FFV1', 'flexfec', 'H261', 'H263', 'H263-1998', 'H263-2000', 'H264', 'H264-RCDO', 'H264-SVC', 'H265', 'H266', 'iso.segment', 'jxsv', 'lottie+json', 'matroska', 'matroska-3d', 'mj2', 'MP1S', 'MP2P', 'MP2T', 'mp4', 'MP4V-ES', 'MPV', 'mpeg', 'mpeg4-generic', 'nv', 'ogg', 'parityfec', 'pointer', 'quicktime', 'raptorfec', 'raw', 'rtp-enc-aescm128', 'rtploopback', 'rtx', 'scip', 'smpte291', 'SMPTE292M', 'ulpfec', 'vc1', 'vc2', 'VP8', 'VP9')



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
		$SignalMessage = $_.ErrorDetails.Message | convertfrom-json
		write-error "HTTP: $StatusCode"
		write-error $SignalMessage.error
		return
	}
	
	write-verbose "HTTP: $StatusCode"
	return $response
}

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

# Receive messages
<#
.SYNOPSIS
    Listens for incoming messages for the configured number.

.DESCRIPTION
    Opens the websocket endpoint '/v1/receive/<number>' and waits until the
    specified amount of messages has been received or the exit word is detected.

.PARAMETER MessageCount
    Number of messages to wait for. Defaults to 1.

.PARAMETER asObject
    Return the received messages as PowerShell objects instead of writing them
    to the console.

.PARAMETER ExitWord
    If this word is received the function stops reading from the websocket.

.PARAMETER NoOutput
    Suppress console output while waiting for messages.
#>
function Receive-SignalMessage {
	[CmdletBinding(ConfirmImpact = 'None',
				PositionalBinding = $false,
				SupportsPaging = $false,
				SupportsShouldProcess = $false)]
	param
	(
		[int]$MessageCount = 1,
		[Parameter(Mandatory = $false)]
		[switch]$asObject,
		[Parameter(Mandatory = $false,
					HelpMessage = 'Stop Zeichenfolge')]
		[string]$ExitWord,
		[switch]$NoOutput
	)
	
	$endpoint = "/v1/receive/{0}" -f [uri]::EscapeDataString($SignalConfig.RegistredNumber)
	$uri = "{0}{1}" -f $SignalConfig.ServerURL.replace("http:", "ws:"), $endpoint
	
	$websocket = [System.Net.WebSockets.ClientWebSocket]::new()
	$websocket.Options.AddSubProtocol("chat")
	$ct = [System.Threading.CancellationToken]::None
	
        Write-Verbose "Connecting to: $uri"
	$websocket.ConnectAsync($uri, $ct).Wait()
	
	$buffer = New-Object byte[] 4096
	$segment = [System.ArraySegment[byte]]::new($buffer)
	
	[System.Collections.ArrayList]$IncomingMessages = @()
    Write-Host "Waiting for message..."
	while ($IncomingMessages.Count -lt $MessageCount) {
		try {
			$result = $websocket.ReceiveAsync($segment, $ct).Result
			if ($result.MessageType -eq [System.Net.WebSockets.WebSocketMessageType]::Close) {
				Write-Host "Connection closed by server"
				break
			}
			$msg = [System.Text.Encoding]::UTF8.GetString($buffer, 0, $result.Count)
			
			$json = $msg.trim() | ConvertFrom-Json
			#if ($json.envelope.typingMessage.action) { write-host $json.envelope.typingMessage.action}
			if ($json.envelope.dataMessage.message) {
				[void]$IncomingMessages.add($json.envelope)
				if (!$NoOutput.IsPresent) {
					write-host ("{3}. {0} ({1}): {2}" -f $json.envelope.sourceName, $json.envelope.sourceNumber, $json.envelope.dataMessage.message, $IncomingMessages.Count)
					if ($json.envelope.dataMessage.message -eq $ExitWord) {
						Write-Verbose "Exit word found. stopping"
						break
					}
				}
			}
		} catch {
            Write-Warning "Invalid JSON line: $msg"
            $websocket.CloseAsync([System.Net.WebSockets.WebSocketCloseStatus]::NormalClosure, "End", $ct).Wait()
			$websocket.Dispose()
			return $msg
		}
	}
	
    $websocket.CloseAsync([System.Net.WebSockets.WebSocketCloseStatus]::NormalClosure, "End", $ct).Wait()
	$websocket.Dispose()
	if ($asObject.IsPresent) {
		return $IncomingMessages
	}
}

# Register device
<#
    .SYNOPSIS
        Registers a new device (phone number) on the Signal network.

    .DESCRIPTION
        This function sends a registration to the Signal network for the specified phone number.
        The registration optionally supports CAPTCHA validation and sending the code via voice call.

        The procedure is:
        - The phone number is sent to the Signal network.
        - Optionally a CAPTCHA token is sent if requested by the server.
        - By default the code is sent via SMS. With the -UseVoice switch a call can be requested instead.

    .PARAMETER Number
        Phone number in international format (e.g. +491234567890) to register with Signal.

    .PARAMETER Captcha
        STEP 1: CAPTCHA token for spam protection, required for certain network requests.
        Obtain the CAPTCHA token by calling the Signal API or by solving a CAPTCHA in the browser.
        CAPTCHA URL: https://signalcaptchas.org/registration/generate
        Press F12 and copy the last URL from the console. Copy the entire text after "signalcaptcha://" (e.g. signal-hcaptcha.5fad97...Gef)

    .PARAMETER UseVoice
        STEP 1: If specified, the verification code is delivered via voice call instead of SMS. Use this parameter instead of 'Captcha'

    .PARAMETER Code
        STEP 2: After the first registration step a code is sent via SMS to the used number. Complete the registration with this code.
	
	.EXAMPLE
		Register-SignalDevice -Number "+491234567890" -Captcha "03AFcWeA..."
		
            Step 1: Start the registration with CAPTCHA token and request the verification code via SMS.
	
	.EXAMPLE
		Register-SignalDevice -Number "+491234567890" -UseVoice
		
            Or step 1: Start the registration and request the verification code via voice call instead of SMS. Unfortunately this does not work with German numbers.
	
	.EXAMPLE
		Register-SignalDevice -Number "+491234567890" -Code
		
            Step 2: Complete the registration for the phone number by submitting the code to Signal.
	
	.NOTES
        This function is part of a PowerShell wrapper for signal-cli and uses the Signal REST API internally.
		Weitere Infos: https://github.com/AsamK/signal-cli/wiki/Registration-with-captcha
#>
function Register-SignalDevice {
	[CmdletBinding(DefaultParameterSetName = 'Step1_C',
				ConfirmImpact = 'None',
				PositionalBinding = $false,
				SupportsPaging = $false,
				SupportsShouldProcess = $false)]
	param
	(
		[Parameter(ParameterSetName = 'Step1_C',
					Mandatory = $true,
					DontShow = $true)]
		[Parameter(ParameterSetName = 'Step1_V')]
		[Parameter(ParameterSetName = 'Step2')]
		[string]$Number,
		[Parameter(ParameterSetName = 'Step1_C')]
		[switch]$Captcha,
		[Parameter(ParameterSetName = 'Step1_V',
					DontShow = $true)]
		[switch]$UseVoice,
		[Parameter(ParameterSetName = 'Step2')]
		[int]$Code
	)
	
	$endpoint = "/v1/register/{0}" -f $SignalConfig.RegistredNumber
	
	$body = @{
		use_voice = $UseVoice.IsPresent
	}
	if ($Captcha.IsPresent) {
		$CaptchaText = read-host -Prompt "signalcaptacha://[YOUR INPUT]"
		$body.add("captcha", $CaptchaText)
	}
	
	if ($Code) {
		$endpoint += "/verify/$code"
		$body = @{
			"pin" = "string"
		}
	}
	
	Invoke-SignalApiRequest -Method 'POST' -Endpoint $endpoint -Body $body
}

# Unregister device
<#
.SYNOPSIS
    Removes the registration for a phone number from the Signal service.

.DESCRIPTION
    Allows deleting the registration and optionally the entire account on the
    server. Local data can also be removed.

.PARAMETER Number
    Phone number in international format to unregister.

.PARAMETER DeleteAccount
    If set, the Signal account is permanently deleted on the server.

.PARAMETER DeleteLocalData
    Remove local data for the device as well.
#>
function Unregister-SignalDevice {
	[CmdletBinding(ConfirmImpact = 'None',
				PositionalBinding = $false,
				SupportsPaging = $false,
				SupportsShouldProcess = $false)]
	param
	(
		[Parameter(Mandatory = $true)]
		[string]$Number,
		[Alias('DA')]
		[switch]$DeleteAccount,
		[switch]$DeleteLocalData
	)
	
	$body = @{
		'delete_account'    = $DeleteAccount.IsPresent
		'delete_local_data' = $DeleteLocalData.IsPresent
	}
	
	$endpoint = "/v1/unregister/{0}" -f $Number
	Invoke-SignalApiRequest -Method 'POST' -Endpoint $endpoint -Body $body
}


# Link device and generate QR code
function Link-SignalDevice {
    <#
    .SYNOPSIS
        Links another device to the current account.

    .DESCRIPTION
        Calls '/v1/qrcodelink' to generate a QR code that can be scanned by the
        Signal client on the device you want to link.

    .PARAMETER DeviceName
        Name of the new device shown in the linked devices list.
    #>
	param (
		[Parameter(Mandatory = $true)]
		[string]$DeviceName
	)
	
        $encodedName = [uri]::EscapeDataString($DeviceName)
        $endpoint = "/v1/qrcodelink?device_name=$encodedName"
        Invoke-SignalApiRequest -Method 'GET' -Endpoint $endpoint
}

<#
.SYNOPSIS
    Retrieves information about the currently registered account.

.DESCRIPTION
    Calls /v1/accounts on the REST API and returns account metadata,
    including linked devices.
#>

function Get-SignalAccount {
	[CmdletBinding(ConfirmImpact = 'None',
				PositionalBinding = $false,
				SupportsPaging = $false,
				SupportsShouldProcess = $false)]
	
	$Endpoint = "/v1/accounts"
	Invoke-SignalApiRequest -Method 'GET' -Endpoint $endpoint
}


# List available groups
<#
    .SYNOPSIS
        Lists Signal groups for the configured account.

    .DESCRIPTION
        Retrieves group metadata from '/v1/groups'. When a GroupId is provided
        only that specific group is returned.

    .PARAMETER GroupId
        Optional ID of a group to fetch. If omitted all groups are listed.
#>
function Get-SignalGroups {
	[CmdletBinding(ConfirmImpact = 'None',
				PositionalBinding = $false,
				SupportsPaging = $false,
				SupportsShouldProcess = $false)]
	param
	(
		[string]$GroupId
	)
	
	$Endpoint = "/v1/groups/{0}" -f $SignalConfig.RegistredNumber
	if ($GroupId) {
		$endpoint += "/$GroupId"
	}
	Invoke-SignalApiRequest -Method 'GET' -Endpoint $endpoint -Verbose:$PSBoundParameters.ContainsKey("Verbose")
}

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
                PS C:\> Update-SignalGroup -GroupID $id -Name "New Name"
                Renames the group.
#>
function Update-SignalGroup {
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

<#
        .SYNOPSIS
                Deletes a Signal group from the account.

        .DESCRIPTION
                Sends a DELETE request to '/v1/groups/<number>/<groupId>' to
                remove the specified group.

        .PARAMETER GroupId
                Identifier of the group to delete.

        .EXAMPLE
                PS C:\> Remove-SignalGroups -GroupId $id
#>
function Remove-SignalGroups {
	[CmdletBinding(ConfirmImpact = 'None',
				PositionalBinding = $false,
				SupportsPaging = $false,
				SupportsShouldProcess = $false)]
	param
	(
		[Parameter(Mandatory = $true)]
		[string]$GroupId
	)
	
	$Endpoint = "/v1/groups/{0}/{1}" -f [uri]::EscapeDataString($SignalConfig.RegistredNumber), [uri]::EscapeDataString($GroupId)
	
	Invoke-SignalApiRequest -Method 'DELETE' -Endpoint $Endpoint
}

