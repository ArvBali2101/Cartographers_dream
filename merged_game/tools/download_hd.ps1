$ErrorActionPreference = 'Stop'
$assetDirectory = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../assets/textures/hd'))
New-Item -ItemType Directory -Path $assetDirectory -Force | Out-Null
$assetHeaders = @{ 'User-Agent' = 'CartographersDream-Hackathon/1.0' }
foreach ($asset in @('rock_wall_07', 'cobblestone_floor_08', 'rock_wall_02')) {
    $metadata = Invoke-RestMethod -Uri "https://api.polyhaven.com/files/$asset" -Headers $assetHeaders
    $maps = @('Diffuse', 'nor_gl', 'Rough')
    if ($asset -eq 'rock_wall_02') { $maps = @('Diffuse', 'nor_gl') }
    foreach ($map in $maps) {
        $file = $metadata.$map.'2k'.jpg
        if (-not $file.url) { throw "Missing 2K JPEG: $asset/$map" }
        $destination = Join-Path $assetDirectory ([IO.Path]::GetFileName(([Uri]$file.url).AbsolutePath))
        if (-not (Test-Path -LiteralPath $destination)) {
            Invoke-WebRequest -Uri $file.url -Headers $assetHeaders -OutFile $destination
        }
        $checksum = (Get-FileHash -LiteralPath $destination -Algorithm MD5).Hash.ToLowerInvariant()
        if ($checksum -ne $file.md5) { throw "Checksum mismatch: $destination" }
        Write-Output "$asset/$map : verified $checksum : $destination"
    }
}
