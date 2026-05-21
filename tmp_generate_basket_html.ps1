$basketDir = Join-Path (Get-Location) 'basket'
$allowed = @('.jpg','.jpeg','.png')
$files = Get-ChildItem -Path $basketDir -File | Where-Object {
    $allowed -contains $_.Extension.ToLower() -and
    $_.BaseName -notlike '*-thumb' -and
    $_.BaseName -notlike '*-full'
} | Sort-Object Name
$html = ''
$delay = 0.1
foreach ($f in $files) {
    $base = [IO.Path]::GetFileNameWithoutExtension($f.Name)
    $ext = $f.Extension.ToLower()
    $thumbName = "$base-thumb$ext"
    $fullName = "$base-full$ext"
    $thumbPath = Join-Path $basketDir $thumbName
    $fullPath = Join-Path $basketDir $fullName
    if (-not (Test-Path $thumbPath)) { $thumbName = $f.Name }
    if (-not (Test-Path $fullPath)) { $fullName = $f.Name }
    $thumbUrl = 'basket/' + [System.Uri]::EscapeDataString($thumbName)
    $fullUrl = 'basket/' + [System.Uri]::EscapeDataString($fullName)
    $alt = $base
    $html += '      <img src="' + $thumbUrl + '" data-full="' + $fullUrl + '" alt="' + $alt + '" style="animation-delay:' + $delay + 's">' + "`r`n"
    $delay = [math]::Round($delay + 0.1, 2)
}
if ($html -eq '') { $html = '      <!-- Nessuna immagine trovata in basket -->`r`n' }
$content = Get-Content galleria.html -Raw
$pattern = '(?s)(<div class="basket-gallery">).*?(</div>)'
$replacement = '$1`r`n' + $html + '      $2'
$new = [regex]::Replace($content, $pattern, $replacement)
Set-Content -Path galleria.html -Value $new
Write-Host '✅ basket-gallery aggiornata con' $files.Count 'immagini';
Write-Host "Sezioni modificate: basket-gallery (calcio rimane intatta)"