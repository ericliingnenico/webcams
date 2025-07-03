$target = "build"
$destination = "C:\TeamCityBuilds\"
$changeLog = "changelog.txt"

if (Test-Path -Path $target) {
    Remove-Item -Recurse $target
}

New-Item -ItemType directory -Path $target

$content = Get-Content $changeLog

foreach($line in $content) {
    $file = $line -split ":"
    $path = Split-Path $file[0] -Parent
    $path = ".\build\" + $path

    New-Item -ItemType Directory -Force -Path $path
    Copy-Item $file[0] –Destination $path -Recurse -Container
}

$date = Get-Date -Format "ddMMyy-HHmmss"
$output = $destination + "webcams_sql_build_" + $date + ".zip"

Add-Type -assembly "system.io.compression.filesystem"
[io.compression.zipfile]::CreateFromDirectory($target, $output)