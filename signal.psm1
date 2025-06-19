# SignalAPI.psm1

# Documentation for signal cli REST API
# https://bbernhard.github.io/signal-cli-rest-api/
#
# Docker image from bbernhard
# bbernhard/signal-cli-rest-api:latest
#
# Git repository from bbernhard
# https://github.com/bbernhard/signal-cli-rest-api

# Konfigurationsvariablen
$SignalServer = 'http://signal.home'
#$SignalServer = 'http://localhost'
$SignalPort = '8080'
$SignalNumber = '+4915202563621'
$SignalURL = "{0}:{1}" -f $SignalServer, $SignalPort


$ImageExtensions = @('aces', 'apng', 'avci', 'avcs', 'avif', 'bmp', 'cgm', 'dpx', 'emf', 'example', 'fits', 'g3fax', 'gif', 'heic', 'heif', 'hej2k', 'ief', 'j2c', 'jaii', 'jais', 'jls', 'jp2', 'jpg','jpeg', 'jph', 'jphc', 'jpm', 'jpx', 'jxl', 'jxr', 'jxrA', 'jxrS', 'jxs', 'jxsc', 'jxsi', 'jxss', 'ktx', 'ktx2', 'naplps', 'png', 'svg+xml', 't38', 'tiff', 'tiff-fx', 'webp', 'wmf')
$TextExtensions = @('cache-manifest', 'calendar', 'cql', 'cql-expression', 'cql-identifier', 'css', 'csv', 'csv-schema', 'dns', 'encaprtp', 'enriched', 'example', 'fhirpath', 'flexfec', 'fwdred', 'gff3', 'grammar-ref-list', 'hl7v2', 'html', 'javascript', 'jcr-cnd', 'markdown', 'mizar', 'n3', 'parameters', 'parityfec', 'plain', 'provenance-notation', 'raptorfec', 'RED', 'rfc822-headers', 'richtext', 'rtf', 'rtp-enc-aescm128', 'rtploopback', 'rtx', 'SGML', 'shaclc', 'shex', 'spdx', 'strings', 't140', 'tab-separated-values', 'troff', 'turtle', 'ulpfec', 'uri-list', 'vcard', 'vtt', 'wgsl', 'xml', 'xml-external-parsed-entity')
$VideoExtensions = @('3gpp', '3gpp2', '3gpp-tt', 'AV1', 'BMPEG', 'BT656', 'CelB', 'DV', 'encaprtp', 'evc', 'example', 'FFV1', 'flexfec', 'H261', 'H263', 'H263-1998', 'H263-2000', 'H264', 'H264-RCDO', 'H264-SVC', 'H265', 'H266', 'iso.segment', 'jxsv', 'lottie+json', 'matroska', 'matroska-3d', 'mj2', 'MP1S', 'MP2P', 'MP2T', 'mp4', 'MP4V-ES', 'MPV', 'mpeg', 'mpeg4-generic', 'nv', 'ogg', 'parityfec', 'pointer', 'quicktime', 'raptorfec', 'raw', 'rtp-enc-aescm128', 'rtploopback', 'rtx', 'scip', 'smpte291', 'SMPTE292M', 'ulpfec', 'vc1', 'vc2', 'VP8', 'VP9')
# Hilfsfunktion zum Senden von HTTP-Anfragen
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
	
	$uri = "{0}{1}" -f $SignalURL, $Endpoint
	
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

# Nachricht senden
<#
	.SYNOPSIS
		Sendet eine Nachricht an einen oder mehrere Empfänger über die Signal-API.
	
	.DESCRIPTION
		A detailed description of the Send-SignalMessage function.
	
	.PARAMETER Recipients
		Eine Liste von Empfängernummern im internationalen Format (z.B. +491234567890) oder Gruppen Id (beginend mit 'group.')
	
	.PARAMETER Message
		Der Nachrichtentext, der gesendet werden soll.
	
	.PARAMETER Path
		Pfad zur Datei, die mitgesendent werden soll
	
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
		number	   = $SignalNumber
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

# Nachrichten empfangen
<#
	.SYNOPSIS
		Empfängt Nachrichten für die konfigurierte Signal-Nummer.
	
	.DESCRIPTION
		A detailed description of the Receive-SignalMessages function.
	
	.PARAMETER MessageCount
		Wartet auf die angegebne Anzahl an Nachrichten, bis es sich beendet.
	
	.PARAMETER asObject
		Ergebnis wird als Array von Objekten zurückgegeben.
	
	.PARAMETER ExitString
		Zeichenfolge, die als Nachricht erwartet wird, um die Konversation zu beenden und die vorherigen Nachrichten auszugeben. Zeichenfolge zwischen 3 und 20 Zeichen
	
	.PARAMETER NoOutput
		Nachrichten nicht auf der Konsole ausgeben. Sinnvoll in Kombination mit asObject
	
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
		[string]$ExitString,
		[switch]$NoOutput
	)
	
	$endpoint = "/v1/receive/{0}" -f [uri]::EscapeDataString($SignalNumber)
	$uri = "{0}{1}" -f $SignalURL.replace("http:", "ws:"), $endpoint
	
	$websocket = [System.Net.WebSockets.ClientWebSocket]::new()
	$websocket.Options.AddSubProtocol("chat")
	$ct = [System.Threading.CancellationToken]::None
	
	Write-verbose "Verbinde zu: $uri"
	$websocket.ConnectAsync($uri, $ct).Wait()
	
	$buffer = New-Object byte[] 4096
	$segment = [System.ArraySegment[byte]]::new($buffer)
	
	[System.Collections.ArrayList]$IncomingMessages = @()
	Write-Host "Warte auf Nachricht..."
	while ($IncomingMessages.Count -lt $MessageCount) {
		try {
			$result = $websocket.ReceiveAsync($segment, $ct).Result
			if ($result.MessageType -eq [System.Net.WebSockets.WebSocketMessageType]::Close) {
				Write-Host "Verbindung geschlossen vom Server"
				break
			}
			$msg = [System.Text.Encoding]::UTF8.GetString($buffer, 0, $result.Count)
			
			$json = $msg.trim() | ConvertFrom-Json
			#if ($json.envelope.typingMessage.action) { write-host $json.envelope.typingMessage.action}
			if ($json.envelope.dataMessage.message) {
				[void]$IncomingMessages.add($json.envelope)
				if (!$NoOutput.IsPresent) {
					write-host ("{3}. {0} ({1}): {2}" -f $json.envelope.sourceName, $json.envelope.sourceNumber, $json.envelope.dataMessage.message, $IncomingMessages.Count)
				}
			}
		} catch {
			Write-Warning "Ungültige JSON-Zeile: $msg"
			$websocket.CloseAsync([System.Net.WebSockets.WebSocketCloseStatus]::NormalClosure, "Ende", $ct).Wait()
			$websocket.Dispose()
			return $msg
		}
	}
	
	$websocket.CloseAsync([System.Net.WebSockets.WebSocketCloseStatus]::NormalClosure, "Ende", $ct).Wait()
	$websocket.Dispose()
	if ($asObject.IsPresent) {
		return $IncomingMessages
	}
}

# Gerät registrieren
<#
	.SYNOPSIS
		Registriert ein neues Gerät (Telefonnummer) im Signal-Netzwerk.
	
	.DESCRIPTION
		Diese Funktion sendet eine Registrierung an das Signal-Netzwerk für die angegebene Telefonnummer.
		Die Registrierung unterstützt optional CAPTCHA-Validierung und den Versand des Codes per Sprachanruf.
		
		Der Ablauf ist:
		- Die Telefonnummer wird an das Signal-Netzwerk gesendet.
		- Optional wird ein CAPTCHA-Token mitgesendet, falls vom Server verlangt.
		- Standardmäßig wird der Code per SMS gesendet. Mit dem Schalter -UseVoice kann stattdessen ein Anruf angefordert werden.
	
	.PARAMETER Number
		Die Telefonnummer im internationalen Format (z.B. +491234567890), die bei Signal registriert werden soll.
	
	.PARAMETER Captcha
		STEP 1: CAPTCHA-Token zur Validierung gegen Spam, erforderlich bei bestimmten Netzwerkanfragen.
		Den CAPTCHA-Token erhält man durch den Aufruf der Signal-API bzw. durch das vorherige Lösen eines CAPTCHA über eine Browser-Abfrage.
		CAPTCH URL: https://signalcaptchas.org/registration/generate
		F12 Drücken und die letzte URL in der Console kopieren. Den gesamten Text hinter "signalcaptcha://" kopieren (also signal-hcaptcha.5fad97...Gef)
	
	.PARAMETER UseVoice
		STEP 1: Wenn angegeben, wird der Bestätigungscode per Sprachanruf statt per SMS zugestellt. Verwenden diesen Paramter anstatt von 'CAPTCHA'
	
	.PARAMETER Code
		STEP 2: Nach dem ERSTEN Schritt der Registrierung wird ein Code per SMS an die verwendete Nummer gesendet. Mit CODE wird die Registierung abgeschlossen.
	
	.EXAMPLE
		Register-SignalDevice -Number "+491234567890" -Captcha "03AFcWeA..."
		
		Schritt 1: Beginn die Registrierung mit CAPTCHA-Token durch und fordert den Bestätigungscode per SMS an.
	
	.EXAMPLE
		Register-SignalDevice -Number "+491234567890" -UseVoice
		
		ODER Schritt 1: Beginn die Registrierung mit und fordert den Bestätigungscode per Anruf statt SMS an. Funktioniert leider nicht mit deutschen Nummern.
	
	.EXAMPLE
		Register-SignalDevice -Number "+491234567890" -Code
		
		Schritt 2: Schließt die Registriererung für die Telefonnummer ab in dem es den Code an Signal übermittelt.

	.NOTES
		Diese Funktion ist Teil eines PowerShell-Wrappers für signal-cli und nutzt intern die REST API von Signal.
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
					Mandatory = $true)]
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
	
	$endpoint = "/v1/register/{0}" -f $Number
	
	$body = @{
		use_voice = $UseVoice.IsPresent
	}
	if ($Captcha.IsPresent) {
		$CaptchaText = read-host -Prompt "signalcaptacha://[YOUR INPUT]"
		$body.add("captcha", $CaptchaText)
	}
	
	if ($Code) {
		$endpoint += "/verify/$code"
		$body = @{"pin" = "string"}
	}
	
	Invoke-SignalApiRequest -Method 'POST' -Endpoint $endpoint -Body $body
	
}

# Gerät unregistrieren
<#
	.SYNOPSIS
		vorhandene Registrierung löschen
	
	.DESCRIPTION
		A detailed description of the Unregister-SignalDevice function.
	
	.PARAMETER Number
		Die Telefonnummer im internationalen Format (z.B. +491234567890).
	
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


# Gerät verlinken und QR-Code generieren
function Link-SignalDevice {
    <#
    .SYNOPSIS
        Verlinkt ein Gerät und generiert einen QR-Code zur Authentifizierung.

    .PARAMETER DeviceName
        Der Name des zu verlinkenden Geräts.
    #>
	param (
		[Parameter(Mandatory = $true)]
		[string]$DeviceName
	)
	
	$endpoint = "/v1/qrcodelink?device_name=$DeviceName"
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


# Verfügbare Gruppen auflisten
<#
	.SYNOPSIS
		Listet alle verfügbaren Signal-Gruppen für die konfigurierte Nummer auf.
	
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
	
	$Endpoint = "/v1/groups/{0}" -f $SignalNumber
	if ($GroupId) {
		$endpoint += "/$GroupId"
	}
	Invoke-SignalApiRequest -Method 'GET' -Endpoint $endpoint
}

# Nachricht an eine Gruppe senden
<#
	.SYNOPSIS
		Sendet eine Nachricht an eine spezifische Signal-Gruppe.
	
	.DESCRIPTION
		create a new signal group
	
	.PARAMETER Name
		Der Nachrichtentext, der gesendet werden soll.
	
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

	$Endpoint = "/v1/groups/$($SignalNumber)"
	
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
	$Endpoint = "/v1/groups/{0}/{1}" -f $SignalNumber, $GroupID
	
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
	
	$Endpoint = "/v1/groups/{0}/{1}" -f [uri]::EscapeDataString($SignalNumber), [uri]::EscapeDataString('group.a0d6WFRZY1Y2aHBuMWhNMjljd2s3aFlqYjd3TDhPOWJhRVFTS0FHeGQyST0=')
	
	Invoke-SignalApiRequest -Method 'DELETE' -Endpoint $Endpoint
}

