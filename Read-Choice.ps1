﻿<#
.SYNOPSIS
Returns choice selected from a list of options.

.PARAMETER Choices
A list of choice strings. Use & in front of a letter to make it a hotkey.

.PARAMETER ChoiceHash
An ordered hash of choices mapped to help text descriptions.
Use & in front of a letter to make it a hotkey.

.PARAMETER Caption
A title to use for the prompt.

.PARAMETER Message
Instructional text to provide in the prompt.

.PARAMETER DefaultIndex
The index of the default choice.
Use -1 to for no default.
Otherwise, the first item (index 0) is the default.

.INPUTS
System.String containing a choice to offer.

.OUTPUTS
System.String containing the choice that was selected.

.LINK
https://msdn.microsoft.com/library/system.management.automation.host.pshostuserinterface.promptforchoice.aspx

.EXAMPLE
Read-Choice.ps1 one,two,three

Please select:
[] one  [] two  [] three  [?] Help (default is "one"):
one

.EXAMPLE
Read-Choice.ps1 ([ordered]@{'&one'='first thing';'&two'='second thing';'t&hree'='third thing'}) -Message 'Pick:'

Pick:
[O] one  [T] two  [H] three  [?] Help (default is "O"): ?
O - first thing
T - second thing
H - third thing
[O] one  [T] two  [H] three  [?] Help (default is "O"):
&one
#>

#Requires -Version 3
[CmdletBinding()][OutputType([string])] Param(
[Parameter(ParameterSetName='ChoicesArray',Position=0,Mandatory=$true,ValueFromPipeline=$true)]
[Alias('Options')][string[]] $Choices,
[Parameter(ParameterSetName='ChoicesHash',Position=0,Mandatory=$true)]
[Alias('Menu')][Collections.IDictionary] $ChoiceHash,
[string] $Caption,
[string] $Message = 'Please select:',
[int] $DefaultIndex
)
End
{
	[Management.Automation.Host.ChoiceDescription[]] $choicelist =
		switch($PSCmdlet.ParameterSetName)
		{
			ChoicesArray
			{
				$Choices = $input.ForEach({$_}) # flatten nested arrays
				$Choices |foreach {New-Object System.Management.Automation.Host.ChoiceDescription $_}
			}
			ChoicesHash
			{
				$Choices = @($ChoiceHash.Keys)
				$Choices |foreach {New-Object System.Management.Automation.Host.ChoiceDescription $_,$ChoiceHash[$_]}
			}
		}
	$Choices[$Host.UI.PromptForChoice($Caption,$Message,$choicelist,$DefaultIndex)]
}
