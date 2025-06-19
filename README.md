# Signal PowerShell Module

This repository contains a PowerShell module that allows you to interact with the [Signal Messenger](https://signal.org/) via the REST API provided by [bbernhard/signal-cli-rest-api](https://github.com/bbernhard/signal-cli-rest-api).

## Goal

The module wraps the REST endpoints exposed by `signal-cli-rest-api` so that they can be consumed easily from PowerShell scripts. It enables sending messages, receiving messages, managing groups, contacts and devices directly from the command line.

**Important:** The module is designed to work with the `json-rpc` mode of `bbernhard/signal-cli-rest-api`. Other modes have not been tested.

## Requirements

- PowerShell 5.1 or later
- A running instance of [`bbernhard/signal-cli-rest-api`](https://github.com/bbernhard/signal-cli-rest-api) configured in `json-rpc` mode. A convenient Docker image is available as `bbernhard/signal-cli-rest-api:latest`.

## Installation

Clone this repository or copy the files somewhere in your `$PSModulePath` and import the module:

```powershell
Import-Module "./signal.psm1"
```

## Configuration

Before using any cmdlet, configure the module with your phone number and the URL of your REST API instance:

```powershell
New-SignalConfiguration -SenderNumber '+491234567890' -SignalServerURL 'http://localhost:8080'
```

This creates a configuration file in the user profile that is loaded automatically whenever the module is imported.

## Examples

### Send a text message

```powershell
Send-SignalMessage -Recipients '+491111111111' -Message 'Hello from PowerShell'
```

### Send a file attachment

```powershell
Send-SignalMessage -Recipients '+491111111111' -Path 'C:\path\to\picture.jpg'
```

### Receive incoming messages

```powershell
Receive-SignalMessage -MessageCount 1
```

### List all groups

```powershell
Get-SignalGroups
```

### Get API information

```powershell
Get-SignalAbout
```

## More information

The full REST API documentation is available at <https://bbernhard.github.io/signal-cli-rest-api/>. For issues or feature requests of the REST API itself please refer to the [signal-cli-rest-api GitHub project](https://github.com/bbernhard/signal-cli-rest-api).

