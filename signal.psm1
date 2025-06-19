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
		create new signal configuration with signal number and url to signal docker container
	
	.DESCRIPTION
		A detailed description of the New-SignalConfigurationx function.
	
	.PARAMETER SenderNumber
		Registred sender number as E.164 format
	
	.PARAMETER SignalServerURL
		URL and Port for signal server like: http://mysignaldocker.local:8080
	
	.EXAMPLE
		PS C:\> New-SignalConfigurationx -SignalNumber 'Value1' -SignalServerURL 'Value2'
	
	.NOTES
		Additional information about the function.
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
		Helper function for creating a Rest Api request in a defined way
	
	.DESCRIPTION
		A detailed description of the Invoke-SignalApiRequest function.
	
	.PARAMETER Method
		A description of the Method parameter.
	
	.PARAMETER Endpoint
		A description of the Endpoint parameter.
	
	.PARAMETER Headers
		A description of the Headers parameter.
	
	.PARAMETER Body
		A description of the Body parameter.
	
	.PARAMETER Header
		Additional header
	
	.EXAMPLE
		PS C:\> Invoke-SignalApiRequest -Method 'GET' -Endpoint 'Value2'
	
	.NOTES
		Additional information about the function.
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
        Sends a message to one or more recipients via the Signal API.
	
	.DESCRIPTION
		A detailed description of the Send-SignalMessage function.
	
    .PARAMETER Recipients
            A list of recipient numbers in international format (e.g. +491234567890) or group IDs beginning with 'group.'

    .PARAMETER Message
            The message text to send.

    .PARAMETER Path
            Path to the file to send along
	
	.NOTES
		Additional information about the function.
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
        Receives messages for the configured Signal number.
	
	.DESCRIPTION
		A detailed description of the Receive-SignalMessages function.
	
    .PARAMETER MessageCount
            Waits for the specified number of messages before finishing.

    .PARAMETER asObject
            Returns the result as an array of objects.

    .PARAMETER ExitString
            String expected as a message to end the conversation and output the previous messages. String between 3 and 20 characters

    .PARAMETER NoOutput
            Do not output messages to the console. Useful together with asObject
	
	.NOTES
		Additional information about the function.
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
                Remove existing registration
	
	.DESCRIPTION
		A detailed description of the Unregister-SignalDevice function.
	
        .PARAMETER Number
                Phone number in international format (e.g. +491234567890).
	
	.PARAMETER DeleteAccount
		If Delete-Account is set to true, the account will be deleted from the Signal Server. This cannot be undone without loss.
	
	.PARAMETER DeleteLocalData
		A description of the DeleteLocalData parameter.
	
	.NOTES
		Additional information about the function.
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
        Links a device and generates a QR code for authentication.

    .PARAMETER DeviceName
        Name of the device to link.
    #>
	param (
		[Parameter(Mandatory = $true)]
		[string]$DeviceName
	)
	
        $encodedName = [uri]::EscapeDataString($DeviceName)
        $endpoint = "/v1/qrcodelink?device_name=$encodedName"
        Invoke-SignalApiRequest -Method 'GET' -Endpoint $endpoint
}

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
        Lists all available Signal groups for the configured number.
	
	.DESCRIPTION
		A detailed description of the Get-SignalGroups function.
	
	.PARAMETER GroupId
		A description of the GroupId parameter.
	
	.NOTES
		Additional information about the function.
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

# Send message to a group
<#
    .SYNOPSIS
        Sends a message to a specific Signal group.
	
	.DESCRIPTION
		create a new signal group
	
    .PARAMETER Name
        The message text to send.
	
	.PARAMETER Members
		A description of the Members parameter.
	
	.PARAMETER Description
		A description of the Description parameter.
	
	.PARAMETER ExpirationTime
		Expiration Time in Seconds. Default is 0
	
	.PARAMETER Number
		A description of the Number parameter.
	
	.NOTES
		Additional information about the function.
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
		Update the state of a Signal Group.
	
	.DESCRIPTION
		Update specific singal group
	
	.PARAMETER Groupid
		A description of the Groupid parameter.
	
	.PARAMETER Name
		A description of the Name parameter.
	
	.PARAMETER Description
		A description of the Description parameter.
	
	.PARAMETER ExpirationTime
		A description of the ExpirationTime parameter.
	
	.PARAMETER FilePath
		Path to photo for avatar. It should be at least 160x160 pixels in size. The maximum file size is 5MB, and the image can be in JPG, PNG, or GIF format.
	
	.EXAMPLE
		PS C:\> Update-SignalGroup
	
	.NOTES
		Additional information about the function.
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
		A brief description of the Remove-SignalGroups function.
	
	.DESCRIPTION
		Delete the specified Signal Group.
	
	.PARAMETER GroupId
		A description of the GroupId parameter.
	
	.EXAMPLE
		PS C:\> Remove-SignalGroups -GroupId 'Value1'
	
	.NOTES
		Additional information about the function.
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

