<#
    .SYNOPSIS
        Receives incoming Signal messages for the configured account.

    .DESCRIPTION
        Establishes a WebSocket connection to the Signal REST API to listen for incoming
        messages in real-time. The function connects to the endpoint on your signal docker 
        container and waits for messages until the specified count is reached or an exit word is
        detected. Messages can be displayed to the console or returned as PowerShell objects
        for further processing. This function is useful for creating automated message
        handlers or monitoring Signal communications.

    .PARAMETER MessageCount
        The number of messages to wait for before automatically stopping. Default is 1.
        Set to a higher number to receive multiple messages in a single session.

    .PARAMETER asObject
        Switch parameter to return received messages as PowerShell objects instead of
        displaying them to the console. Use this when you need to process messages
        programmatically or store them for later use.

    .PARAMETER ExitWord
        Optional exit word that will cause the function to stop listening when received
        in a message. This provides a way to remotely control the listening session
        by sending a specific keyword.

    .PARAMETER NoOutput
        Switch parameter to suppress console output while waiting for messages. The
        function will still receive messages but won't display them to the console.
        Useful when running in automated scenarios.

    .EXAMPLE
        Receive-SignalMessage
        
        Waits for one incoming Signal message and displays it to the console.

    .EXAMPLE
        Receive-SignalMessage -MessageCount 5
        
        Waits for up to 5 incoming messages before stopping.

    .EXAMPLE
        $messages = Receive-SignalMessage -MessageCount 10 -asObject
        
        Receives up to 10 messages and returns them as PowerShell objects for processing.

    .EXAMPLE
        Receive-SignalMessage -ExitWord "STOP" -MessageCount 100
        
        Listens for up to 100 messages but stops immediately if "STOP" is received.

    .EXAMPLE
        Receive-SignalMessage -NoOutput -asObject -MessageCount 5
        
        Silently receives 5 messages and returns them as objects without console output.

    .OUTPUTS
        System.Object[]
        When -asObject is specified, returns an array of message objects containing
        sender information, message content, and metadata. Otherwise, no output is returned.

    .NOTES
        Requires a configured Signal account via Set-SignalConfiguration.
        Uses WebSocket connection for real-time message reception.
        The function blocks execution until the specified conditions are met.
        Network connectivity to the Signal server is required throughout the session.
        Messages are received in real-time as they arrive at the Signal server.
        The WebSocket connection is automatically closed when the function completes.

    .LINK
        Send-SignalMessage
        Get-SignalConfiguration
        Set-SignalConfiguration
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