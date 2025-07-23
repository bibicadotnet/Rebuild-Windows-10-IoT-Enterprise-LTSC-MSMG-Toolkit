param(
    [string]$DownloadPath = "C:\WindowsUpdates"
)

Write-Host "=== KIỂM TRA VÀ DOWNLOAD WINDOWS UPDATES ===" -ForegroundColor Green
Write-Host "Thư mục lưu file: $DownloadPath" -ForegroundColor Yellow

# Tạo thư mục nếu chưa có
if (-not (Test-Path $DownloadPath)) {
    New-Item -Path $DownloadPath -ItemType Directory -Force | Out-Null
    Write-Host "Đã tạo thư mục: $DownloadPath" -ForegroundColor Green
}

# Kiểm tra và cài đặt module kbupdate nếu cần
Write-Host "`nKiểm tra module kbupdate..." -ForegroundColor Yellow
if (-not (Get-Module -ListAvailable -Name kbupdate)) {
    Write-Host "Đang cài đặt module kbupdate..." -ForegroundColor Yellow
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
    Install-Module kbupdate -Force -AllowClobber -Scope CurrentUser
}

# Import module
Import-Module kbupdate -Force

# Kiểm tra các update cần thiết
Write-Host "`nĐang kiểm tra các update cần thiết..." -ForegroundColor Yellow
try {
    $neededUpdates = Get-KbNeededUpdate
    
    if ($neededUpdates) {
        Write-Host "Tìm thấy $($neededUpdates.Count) update(s) cần thiết:" -ForegroundColor Green
        
        # Hiển thị danh sách
        foreach ($update in $neededUpdates) {
            Write-Host "  - $($update.Title)" -ForegroundColor Cyan
        }
        
        # Download các updates
        Write-Host "`nBắt đầu download..." -ForegroundColor Yellow
        $neededUpdates | Save-KbUpdate -Path $DownloadPath
        
        Write-Host "`nHoàn thành! Các file đã được lưu tại: $DownloadPath" -ForegroundColor Green
        
        # Hiển thị các file đã download
        $downloadedFiles = Get-ChildItem -Path $DownloadPath -Filter "*.msu" | Sort-Object LastWriteTime -Descending
        if ($downloadedFiles) {
            Write-Host "`nCác file .msu đã download:" -ForegroundColor Green
            foreach ($file in $downloadedFiles) {
                $size = [math]::Round($file.Length/1MB, 2)
                Write-Host "  - $($file.Name) ($size MB)" -ForegroundColor White
            }
        }
        
    } else {
        Write-Host "Không có update nào cần thiết. Hệ thống đã được cập nhật đầy đủ." -ForegroundColor Green
    }
    
} catch {
    Write-Host "Lỗi: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n=== XONG ===" -ForegroundColor Green
