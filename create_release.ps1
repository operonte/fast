# Script para crear release en GitHub
# Requiere: Token de acceso personal de GitHub

param(
    [string]$GitHubToken = $env:GITHUB_TOKEN
)

$repo = "operonte/fast"
$tag = "v1.0.0"
$releaseName = "Fast v1.0.0"
$apkPath = "build\app\outputs\flutter-apk\app-release.apk"

# Verificar que existe la APK
if (-not (Test-Path $apkPath)) {
    Write-Host "Error: No se encontró la APK en $apkPath" -ForegroundColor Red
    Write-Host "Ejecuta primero: flutter build apk --release" -ForegroundColor Yellow
    exit 1
}

# Verificar token
if (-not $GitHubToken) {
    Write-Host "Error: Se requiere un token de GitHub" -ForegroundColor Red
    Write-Host ""
    Write-Host "Opciones:" -ForegroundColor Yellow
    Write-Host "1. Crear un token en: https://github.com/settings/tokens" -ForegroundColor Cyan
    Write-Host "2. Dar permisos: repo (full control)" -ForegroundColor Cyan
    Write-Host "3. Ejecutar: `$env:GITHUB_TOKEN='tu_token'; .\create_release.ps1" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "O crear el release manualmente desde la interfaz web de GitHub" -ForegroundColor Yellow
    exit 1
}

$releaseNotes = @"
## 🎉 Primera versión de Fast

### ✨ Características principales

- 📱 Envío directo a WhatsApp desde la app
- 🌍 Soporte para códigos de país (optimizado para Chile)
- 💬 Mensajes predefinidos
- 📋 Historial de números recientes
- ⚙️ Configuraciones personalizables
- 🎨 5 temas disponibles (Rosa, Verde, Celeste, Oscuro, Sistema)
- 🔢 Validación inteligente de números
- ✨ Interfaz moderna con Material Design 3

### 🔒 Privacidad

- Todos los datos se almacenan localmente
- Sin recopilación de información
- Sin tracking ni analytics
- [Política de privacidad](https://operonte.github.io/fast/privacy_policy.html)

### 📥 Instalación

1. Descarga el archivo `app-release.apk`
2. En tu dispositivo Android, ve a **Configuración > Seguridad**
3. Activa **"Permitir instalación de aplicaciones de fuentes desconocidas"**
4. Abre el archivo APK e instala

### 📝 Notas técnicas

- Versión: 1.0.0
- Tamaño: ~45.6 MB
- Plataforma: Android
- Requiere: Android 5.0+ (API 21+)

---

**Desarrollado con ❤️ por Cristian Bravo Droguett**
"@

Write-Host "Creando release en GitHub..." -ForegroundColor Cyan

# Crear el release
$releaseBody = @{
    tag_name = $tag
    name = $releaseName
    body = $releaseNotes
    draft = $false
    prerelease = $false
} | ConvertTo-Json

$headers = @{
    "Authorization" = "token $GitHubToken"
    "Accept" = "application/vnd.github.v3+json"
}

try {
    $createResponse = Invoke-RestMethod -Uri "https://api.github.com/repos/$repo/releases" -Method Post -Headers $headers -Body $releaseBody -ContentType "application/json"
    $releaseId = $createResponse.id
    Write-Host "✅ Release creado exitosamente (ID: $releaseId)" -ForegroundColor Green
    
    # Subir la APK
    Write-Host "Subiendo APK..." -ForegroundColor Cyan
    $uploadUrl = $createResponse.upload_url -replace '\{.*\}', "?name=app-release.apk"
    
    $fileBytes = [System.IO.File]::ReadAllBytes((Resolve-Path $apkPath))
    $boundary = [System.Guid]::NewGuid().ToString()
    
    $uploadHeaders = @{
        "Authorization" = "token $GitHubToken"
        "Accept" = "application/vnd.github.v3+json"
        "Content-Type" = "application/vnd.android.package-archive"
    }
    
    $uploadResponse = Invoke-RestMethod -Uri $uploadUrl -Method Post -Headers $uploadHeaders -Body $fileBytes
    
    Write-Host "✅ APK subida exitosamente!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Release disponible en: $($createResponse.html_url)" -ForegroundColor Cyan
    
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.ErrorDetails.Message) {
        Write-Host "Detalles: $($_.ErrorDetails.Message)" -ForegroundColor Red
    }
    exit 1
}

