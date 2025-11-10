# Script de Deploy Automático para GitHub
# Este script faz commit e push automático para acionar o build da imagem Docker

Write-Host "🚀 Iniciando deploy automático..." -ForegroundColor Cyan

# Verificar se há mudanças
$status = git status --porcelain
if ([string]::IsNullOrWhiteSpace($status)) {
    Write-Host "✅ Nenhuma mudança detectada. Nada para fazer." -ForegroundColor Green
    exit 0
}

# Mostrar mudanças
Write-Host "`n📝 Mudanças detectadas:" -ForegroundColor Yellow
git status --short

# Adicionar todos os arquivos
Write-Host "`n📦 Adicionando arquivos..." -ForegroundColor Cyan
git add .

# Criar commit com timestamp
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$commitMessage = "Deploy automático - $timestamp"

Write-Host "💾 Criando commit: $commitMessage" -ForegroundColor Cyan
git commit -m $commitMessage

# Push para GitHub
Write-Host "`n🌐 Enviando para GitHub..." -ForegroundColor Cyan
git push origin main

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✅ Deploy concluído com sucesso!" -ForegroundColor Green
    Write-Host "`n📋 Próximos passos:" -ForegroundColor Yellow
    Write-Host "1. Acesse: https://github.com/Bluebytedev/uno/actions" -ForegroundColor White
    Write-Host "2. Aguarde o build da imagem Docker (2-5 minutos)" -ForegroundColor White
    Write-Host "3. Atualize a stack no Portainer com 'Pull and redeploy'" -ForegroundColor White
    Write-Host "`n🐳 Imagem será publicada em: ghcr.io/bluebytedev/uno:latest" -ForegroundColor Cyan
} else {
    Write-Host "`n❌ Erro ao fazer push. Verifique suas credenciais do GitHub." -ForegroundColor Red
    exit 1
}
