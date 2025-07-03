$nuget = "C:\BuildTools\nuget.exe"
$vs = "C:\Program Files (x86)\Microsoft Visual Studio\2017\Professional\"

Task Build-eCAMS -Depends RestorePackages {
    $devenv = "$($vs)Common7\IDE\devenv.com"

    Write-Host "Building eCAMS" -ForegroundColor Green

	XmlDocTransform (Resolve-Path ".\eCAMS\Web.config") (Resolve-Path ".\eCAMS\Web.Release.config")
	XmlDocTransform (Resolve-Path ".\wseCAMS\Web.config") (Resolve-Path ".\wseCAMS\Web.Release.config")

    & $devenv eCAMSSource2010.sln /build Release
}

Task PackageAndDeploy-WebCAMS -Depends Build-eCAMS {
    $octo = "C:\BuildTools\octo.exe"
    $version = GetVersionNumber

    Write-Host "Building Packages" -ForegroundColor Green

    & $octo pack --id=CAMS.WebCAMS.eCAMS --basePath=.\eCAMSSetup\Release --outFolder=.\eCAMSSetup\Release --version="$($version)"
    & $octo pack --id=CAMS.WebCAMS.wseCAMS --basePath=.\wseCAMSSetup\Release --outFolder=.\wseCAMSSetup\Release --version="$($version)"

    PushPackage ".\eCAMSSetup\Release\CAMS.WebCAMS.eCAMS.$($version).nupkg"
    PushPackage ".\wseCAMSSetup\Release\CAMS.WebCAMS.wseCAMS.$($version).nupkg"
}

Task RestorePackages {
    Write-Host "Restoring Packages" -ForegroundColor Green
	& $nuget restore -PackagesDirectory ./packages
}

Function PushPackage($path) {
    & $nuget push $path -ApiKey API-L6IJYTYAVXXPOLHCSJSJEDUI9UO -Source https://octodev01.ippayments.com.au/nuget/packages
}

Function GetVersionNumber() {
	$month = get-date -Uformat %m
	$date = get-date -Uformat %d
	Return "1.0.0"+$month+$date+"."+$buildNumber
}

Function XmlDocTransform($xml, $xdt)
{
    if (!$xml -or !(Test-Path -path $xml -PathType Leaf)) {
        throw "File not found. $xml";
    }

    if (!$xdt -or !(Test-Path -path $xdt -PathType Leaf)) {
        throw "File not found. $xdt";
    }

    Add-Type -LiteralPath "$($vs)MSBuild\Microsoft\VisualStudio\v15.0\Web\Microsoft.Web.XmlTransform.dll"

    $xmldoc = New-Object Microsoft.Web.XmlTransform.XmlTransformableDocument;
    $xmldoc.PreserveWhitespace = $true
    $xmldoc.Load($xml);

    $transf = New-Object Microsoft.Web.XmlTransform.XmlTransformation($xdt);

    if ($transf.Apply($xmldoc) -eq $false)
    {
        throw "Transformation failed."
    }

    $xmldoc.Save($xml);
}