$ErrorActionPreference = 'Stop'
$figureDirectory = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../assets/models/gothic_figure'))
New-Item -ItemType Directory -Path $figureDirectory -Force | Out-Null
$headers = @{ 'User-Agent' = 'CartographersDream-Hackathon/1.0' }
$metadata = Invoke-RestMethod 'https://api.polyhaven.com/files/gothic_statue' -Headers $headers
$model = $metadata.gltf.'2k'.gltf
$files = @(@{ relative = 'gothic_statue_2k.gltf'; source = $model })
foreach ($dependency in $model.include.PSObject.Properties) {
    $files += @{ relative = $dependency.Name; source = $dependency.Value }
}
foreach ($file in $files) {
    $target = [IO.Path]::GetFullPath((Join-Path $figureDirectory $file.relative))
    if (-not $target.StartsWith($figureDirectory + [IO.Path]::DirectorySeparatorChar)) { throw 'Invalid model dependency path' }
    New-Item -ItemType Directory -Path ([IO.Path]::GetDirectoryName($target)) -Force | Out-Null
    if (-not (Test-Path -LiteralPath $target)) { Invoke-WebRequest $file.source.url -Headers $headers -OutFile $target }
    $hash = (Get-FileHash -LiteralPath $target -Algorithm MD5).Hash.ToLowerInvariant()
    if ($hash -ne $file.source.md5) { throw "Checksum failed: $target" }
    Write-Output "Verified $($file.relative): $hash"
}
