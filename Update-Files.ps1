﻿<#
.SYNOPSIS
Copies specified source files that exist in the destination directory.

.PARAMETER Path
Path(s) to copy files from, wildcards allowed.

.PARAMETER Destination
Folder to copy files to, if they already exist there.

.PARAMETER NewerOnly
Indicates files should only be copied if they are newer.

.INPUTS
System.String of paths to copy from, if matches exist in the destination.

.EXAMPLE
Update-Files.ps1 C:\Source\*.txt D:\Dest

Copies *.txt files from C:\Source to D:\Dest that exist in both.
#>

#Requires -Version 3
[CmdletBinding(SupportsShouldProcess=$true)][OutputType([void])] Param(
[Parameter(Position=0,ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true,Mandatory=$true)][string[]] $Path,
[ValidateScript({Test-Path $_ -PathType Container})][Parameter(Position=1)][string] $Destination,
[switch] $NewerOnly
)

Process
{
    foreach($file in Resolve-Path $Path)
    {
        $destfile = Join-Path $Destination ([IO.Path]::GetFileName($file))
        if(!(Test-Path $destfile -PathType Leaf)) {continue}
        if((!$NewerOnly -or (Test-NewerFile.ps1 "$destfile" "$file")) -and
            $PSCmdlet.ShouldProcess("'$file' over '$destfile'",'copy'))
        {cp $file $destfile}
    }
}
