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