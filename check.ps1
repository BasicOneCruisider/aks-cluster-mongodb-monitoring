Write-Host "Git Security Check" -ForegroundColor Green

$files = @("terraform.tfvars", "terraform.tfstate", "cluster-config.json")

foreach ($file in $files) {
    if (Test-Path $file) {
        Write-Host "SENSITIVE FILE FOUND: $file" -ForegroundColor Red
    } else {
        Write-Host "OK: $file not present" -ForegroundColor Green
    }
}

if (Test-Path ".gitignore") {
    Write-Host "gitignore exists" -ForegroundColor Green
} else {
    Write-Host "gitignore missing" -ForegroundColor Red
}

Write-Host "Done"