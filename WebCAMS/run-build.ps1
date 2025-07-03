[CmdletBinding()]
Param(
    [Parameter(Mandatory=$False, Position=0, HelpMessage='Task to run')]
    [string]$task = 'PackageAndDeploy-WebCAMS',

    [Parameter(Mandatory=$True, Position=1, HelpMessage='Build number')]
    [string]$buildNumber = '1'
)

$scriptPath = Split-Path $MyInvocation.InvocationName

Import-Module (join-path $scriptPath psake.psm1) -force
Invoke-psake (join-path $scriptPath default.ps1) -framework '4.5.1' -parameters @{buildNumber=$buildNumber} -taskList $task

if ($psake.build_success -eq $false) { exit 1 } else { exit 0 }