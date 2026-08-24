$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$app = Join-Path $root 'hexagon'
$minioDir = Join-Path $root 'minio'
New-Item -ItemType Directory -Force -Path $minioDir | Out-Null
$minio = Join-Path $minioDir 'minio.exe'
if (-not (Test-Path $minio)) {
  Write-Host 'Downloading free local MinIO storage...'
  Invoke-WebRequest 'https://dl.min.io/server/minio/release/windows-amd64/minio.exe' -OutFile $minio
}
$envFile = Join-Path $app '.env'
$envText = Get-Content $envFile -Raw
$envText = $envText -replace '(?m)^S3_ENDPOINT=.*\r?\n?', ''
$envText = $envText -replace '(?m)^CLOUDFLARE_S3_ACCOUNT_ID=.*\r?\n?', ''
$envText = $envText -replace '(?m)^CLOUDFLARE_S3_ACCESS_KEY_ID=.*\r?\n?', ''
$envText = $envText -replace '(?m)^CLOUDFLARE_S3_ACCESS_KEY=.*\r?\n?', ''
$envText += "`nS3_ENDPOINT=http://127.0.0.1:9001`nCLOUDFLARE_S3_ACCOUNT_ID=local`nCLOUDFLARE_S3_ACCESS_KEY_ID=minioadmin`nCLOUDFLARE_S3_ACCESS_KEY=minioadmin`n"
Set-Content $envFile $envText -NoNewline
$files = @(
  (Join-Path $app 'src/lib/server/s3.ts'),
  (Join-Path $app 'src/hooks.server.ts')
)
foreach ($file in $files) {
  $text = Get-Content $file -Raw
  $text = $text.Replace('endpoint: `https://${env.CLOUDFLARE_S3_ACCOUNT_ID as string}.r2.cloudflarestorage.com`,', 'endpoint: env.S3_ENDPOINT || `https://${env.CLOUDFLARE_S3_ACCOUNT_ID as string}.r2.cloudflarestorage.com`,')
  $text = $text.Replace('endpoint: `https://${env.CLOUDFLARE_S3_ACCOUNT_ID}.r2.cloudflarestorage.com`,', 'endpoint: env.S3_ENDPOINT || `https://${env.CLOUDFLARE_S3_ACCOUNT_ID}.r2.cloudflarestorage.com`,')
  Set-Content $file $text -NoNewline
}
$running = Get-Process minio -ErrorAction SilentlyContinue
if (-not $running) {
  New-Item -ItemType Directory -Force -Path (Join-Path $minioDir 'data') | Out-Null
  $cmd = "set MINIO_ROOT_USER=minioadmin&&set MINIO_ROOT_PASSWORD=minioadmin&&`"$minio`" server `"$(Join-Path $minioDir 'data')`" --address 127.0.0.1:9001 --console-address 127.0.0.1:9002"
  Start-Process cmd.exe -ArgumentList '/c', $cmd -WindowStyle Minimized
  Start-Sleep -Seconds 3
}
Write-Host 'Local MinIO storage is ready.'
