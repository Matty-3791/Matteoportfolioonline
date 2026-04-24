# Script PowerShell per ottimizzare immagini
# Usa .NET per il ridimensionamento

Add-Type -AssemblyName System.Drawing
[System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") | Out-Null

$portfolioDir = Get-Location
$thumbSize = 350
$fullSize = 1200
$processed = 0

function Resize-Image {
    param(
        [string]$InputPath,
        [string]$OutputPath,
        [int]$MaxSize
    )
    
    try {
        $img = [System.Drawing.Image]::FromFile($InputPath)
        $width = $img.Width
        $height = $img.Height
        
        # Calcola proporzioni
        if ($width -gt $height) {
            $newWidth = $MaxSize
            $newHeight = [int]($height * ($MaxSize / $width))
        } else {
            $newHeight = $MaxSize
            $newWidth = [int]($width * ($MaxSize / $height))
        }
        
        $resized = New-Object System.Drawing.Bitmap($newWidth, $newHeight)
        $graphic = [System.Drawing.Graphics]::FromImage($resized)
        $graphic.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graphic.DrawImage($img, 0, 0, $newWidth, $newHeight)
        
        # Salva con qualità
        $encoder = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | 
                   Where-Object { $_.MimeType -eq 'image/jpeg' }
        $encoderParams = New-Object System.Drawing.Imaging.EncoderParameters(1)
        $encoderParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, 90)
        
        $resized.Save($OutputPath, $encoder, $encoderParams)
        $graphic.Dispose()
        $resized.Dispose()
        $img.Dispose()
        
        Write-Host "✅ $(Split-Path $InputPath -Leaf)" -ForegroundColor Green
        return $true
    } catch {
        Write-Host "❌ $(Split-Path $InputPath -Leaf): $_" -ForegroundColor Red
        return $false
    }
}

Write-Host "`n📸 ELABORO BASKET (BRY)..." -ForegroundColor Cyan
Get-ChildItem "BRY_*.jpg" -ErrorAction SilentlyContinue | ForEach-Object {
    if (Resize-Image $_.FullName "$($_.DirectoryName)\$($_.BaseName)-thumb.jpg" $thumbSize) {
        Resize-Image $_.FullName "$($_.DirectoryName)\$($_.BaseName)-full.jpg" $fullSize
        $processed++
    }
}

Write-Host "`n⚽ ELABORO CALCIO (MAT)..." -ForegroundColor Cyan
Get-ChildItem "MAT*.jpg" -ErrorAction SilentlyContinue | ForEach-Object {
    if (Resize-Image $_.FullName "$($_.DirectoryName)\$($_.BaseName)-thumb.jpg" $thumbSize) {
        Resize-Image $_.FullName "$($_.DirectoryName)\$($_.BaseName)-full.jpg" $fullSize
        $processed++
    }
}

Write-Host "`n🎨 ELABORO EDIT..." -ForegroundColor Cyan
Get-ChildItem "edit\*" -Include "*.jpg", "*.png" -ErrorAction SilentlyContinue | ForEach-Object {
    if (Resize-Image $_.FullName "$($_.DirectoryName)\$($_.BaseName)-thumb$($_.Extension)" $thumbSize) {
        Resize-Image $_.FullName "$($_.DirectoryName)\$($_.BaseName)-full$($_.Extension)" $fullSize
        $processed++
    }
}

Write-Host "`n✨ OTTIMIZZAZIONE COMPLETATA!" -ForegroundColor Green
Write-Host "Immagini elaborate: $processed" -ForegroundColor Yellow
