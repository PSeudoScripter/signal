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
		More Information: https://github.com/AsamK/signal-cli/wiki/Registration-with-captcha
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