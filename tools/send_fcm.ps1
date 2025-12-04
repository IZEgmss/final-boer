param(
  [string]$ProjectId = "finalboer-3bb5d",
  [string]$Token,
  [string]$Title = "Compra Confirmada",
  [string]$Body  = "Seu pedido foi processado com sucesso!",
  [string]$PedidoId = "12345",
  [switch]$UseClipboard
)

function Get-AccessToken {
  $gcloudCmd = Join-Path $env:LOCALAPPDATA "Google\Cloud SDK\google-cloud-sdk\bin\gcloud.cmd"
  if (Test-Path $gcloudCmd) {
    $token = & $gcloudCmd auth application-default print-access-token
    if (-not $token) { throw "Falha ao obter ACCESS_TOKEN via gcloud.cmd." }
    return $token.Trim()
  }
  $gcloud = Get-Command gcloud.cmd -ErrorAction SilentlyContinue
  if ($gcloud) {
    $token = & $gcloud.Source auth application-default print-access-token
    if (-not $token) { throw "Falha ao obter ACCESS_TOKEN via gcloud.cmd (PATH)." }
    return $token.Trim()
  }
  throw "gcloud não encontrado. Instale e execute 'gcloud auth application-default login'."
}

function Get-DeviceToken {
  if ($Token) { return $Token }
  $filePath = Join-Path $PSScriptRoot "token.txt"
  if (Test-Path $filePath) { return (Get-Content $filePath -TotalCount 1).Trim() }
  if ($UseClipboard) {
    try { return (Get-Clipboard).Trim() } catch { throw "Clipboard vazio. Forneça -Token ou crie tools/token.txt." }
  }
  throw "Token não fornecido. Use -Token, -UseClipboard ou crie tools/token.txt."
}

$accessToken = Get-AccessToken
$deviceToken = Get-DeviceToken

$body = @{ message = @{ token = $deviceToken; notification = @{ title = $Title; body = $Body }; data = @{ pedidoId = $PedidoId } } }
$json = $body | ConvertTo-Json -Depth 10

$uri = "https://fcm.googleapis.com/v1/projects/$ProjectId/messages:send"

$headers = @{ Authorization = "Bearer $accessToken"; "Content-Type" = "application/json" }

$response = Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -Body $json -ErrorAction Stop
Write-Output ($response | ConvertTo-Json -Depth 10)
