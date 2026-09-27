$ErrorActionPreference = 'Stop'
$idolDirectory = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../assets/models/forbidden_idol'))
New-Item -ItemType Directory -Path $idolDirectory -Force | Out-Null
$metadata = Invoke-RestMethod 'https://api.polyhaven.com/files/gothic_statue'
$model = $metadata.gltf.'4k'.gltf
$files = @(@{ relative = 'gothic_statue_4k.gltf'; source = $model })
foreach ($dependency in $model.include.PSObject.Properties) {
    $files += @{ relative = $dependency.Name; source = $dependency.Value }
}
foreach ($file in $files) {
    $target = [IO.Path]::GetFullPath((Join-Path $idolDirectory $file.relative))
    if (-not $target.StartsWith($idolDirectory + [IO.Path]::DirectorySeparatorChar)) { throw 'Invalid idol dependency path' }
    New-Item -ItemType Directory -Path ([IO.Path]::GetDirectoryName($target)) -Force | Out-Null
    if (-not (Test-Path -LiteralPath $target)) { Invoke-WebRequest $file.source.url -OutFile $target }
    $hash = (Get-FileHash -LiteralPath $target -Algorithm MD5).Hash.ToLowerInvariant()
    if ($hash -ne $file.source.md5) { throw "Checksum failed: $target" }
    Write-Output "Verified $($file.relative): $hash"
}
