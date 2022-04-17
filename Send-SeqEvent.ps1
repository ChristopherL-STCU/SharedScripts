﻿<#
.SYNOPSIS
Send an event to a Seq server.

.PARAMETER Message
The text to use as the log message, a Seq template unless -LiteralMessage is present.
By default, the value of the Message property will be used.

.PARAMETER Properties
Logging properties to record in Seq, as an OrderedDictionary, Hashtable, DataRow,
or any object with properties to use.

.PARAMETER Level
The type of event to record.
Information by default.

.PARAMETER Server
The URL of the Seq server.

.PARAMETER ApiKey
The Seq API key to use.

.PARAMETER LiteralMessage
When present, indicates the Message parameter is to be used verbatim, not as a Seq template.

.INPUTS
System.Collections.Hashtable
or System.Collections.Specialized.OrderedDictionary
or System.Data.DataRow
or an object

.LINK
Invoke-RestMethod

.LINK
https://getseq.net/

.EXAMPLE
Send-SeqEvent.ps1 'Hello from PowerShell' -Server http://my-seq -LiteralMessage

.EXAMPLE
Send-SeqEvent.ps1 'Event: {User} on {Machine}' @{ User = $env:UserName; Machine = $env:ComputerName } -Server http://my-seq

.EXAMPLE
Send-SeqEvent.ps1 -Properties @{ Message = $Error[0].Exception.Message } -Level Error -Server http://my-seq
#>

#requires -Version 4
[CmdletBinding()][OutputType([void])] Param(
[Parameter(Position=0)][Alias('Text')][string] $Message = '{Message}',
[Parameter(Mandatory=$true,Position=1,ValueFromPipeline=$true)][Alias('Parameters')] $Properties,
[ValidateSet('Verbose','Debug','Information','Warning','Error','Fatal')][string] $Level = 'Information',
[uri] $Server,
[string] $ApiKey,
[switch] $LiteralMessage
)
Process
{
    if($Properties -is [hashtable]) {}
    elseif($Properties -is [Collections.Specialized.OrderedDictionary]) {}
    elseif($Properties -is [Data.DataRow]) {$Properties = ConvertFrom-DataRow.ps1 $Properties -AsHashtable}
    else {$Properties = ConvertTo-OrderedDictionary.ps1 $Properties}

    if($LiteralMessage) { $Properties += @{Message=$Message}; $Message = "{Message}" }

    @{
        Uri         = New-Object uri ([uri]$Server,"/api/events/raw?apiKey=$ApiKey")
        Method      = 'POST'
        ContentType = 'application/json'
        Body        = @{
            Events  = @(
                @{
                    Timestamp       = Get-Date -Format o
                    Level           = $Level
                    MessageTemplate = $Message
                    Properties      = $Properties
                }
            )
        } |ConvertTo-Json -Depth 5 -Compress
    } |% {Invoke-RestMethod @_ |Write-Verbose}
}
