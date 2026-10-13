param([string]$Secret = $env:CLIENT_SECRET)

$token = (Invoke-RestMethod -Method Post -Uri "http://localhost:8180/realms/api-gateway-realm/protocol/openid-connect/token" -Body @{ grant_type="password"; client_id="api-gateway-client"; client_secret=$Secret; username="testuser"; password="test123" }).access_token

function Test-Call($label, $expected, $headers) {
    $args = @("-s","-o","NUL","-w","%{http_code}")
    foreach ($h in $headers) { $args += @("-H", $h) }
    $code = curl.exe @args $script:url
    $ok = if ($code -eq $expected) { "PASS" } else { "FAIL" }
    Write-Host ("{0,-45} expected {1}  got {2}  [{3}]" -f $label, $expected, $code, $ok)
    Start-Sleep 3
}

$url = $null
$url = "http://localhost:8082/demo/hello"
Write-Host "=== Security tests ==="
Test-Call "No token -> /demo/hello"            401 @()
Test-Call "Valid token -> /demo/hello"         200 @("Authorization: Bearer $token")
$url = "http://localhost:8082/demo/admin-only"
Test-Call "Normal user -> /demo/admin-only"    403 @("Authorization: Bearer $token")