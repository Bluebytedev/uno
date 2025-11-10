# 🚀 Instruções de Deploy Automático

## ✅ Configuração Completa

Tudo já está configurado! Você só precisa seguir os passos abaixo.

---

## 📋 Passo a Passo

### 1️⃣ Fazer Deploy Inicial (APENAS UMA VEZ)

Execute o script de deploy:

```powershell
.\deploy.ps1
```

Ou manualmente:

```powershell
git add .
git commit -m "Deploy inicial com Baileys v7"
git push origin main
```

### 2️⃣ Acompanhar o Build no GitHub

1. Acesse: **https://github.com/Bluebytedev/uno/actions**
2. Aguarde o workflow **"Build and Push Docker Image"** finalizar (2-5 minutos)
3. Quando aparecer ✅ verde, a imagem está pronta!

### 3️⃣ Configurar Permissões do Package (Primeira Vez)

1. Acesse: **https://github.com/Bluebytedev/uno/packages**
2. Clique no package **uno**
3. **Package settings** → **Change visibility** → **Public**
4. Salvar

> ⚠️ Se preferir manter privado, configure credenciais no Portainer (veja seção abaixo)

### 4️⃣ Atualizar Stack no Portainer

#### Copie este conteúdo para sua stack:

```yaml
version: '3'

x-base: &base
  image: ghcr.io/bluebytedev/uno:latest
  entrypoint: echo 'ok!'
  networks:
    - minio
    - rabbitmq
    - redis
  environment:
    NODE_OPTIONS: --max-old-space-size=14096
    
    # --- Conexões ---
    AMQP_URL: ${AMQP_URL}
    REDIS_URL: ${REDIS_URL}
    BASE_URL: ${BASE_URL}

    # --- Storage / S3 ---
    STORAGE_REGION: ${STORAGE_REGION:-sa-east-1}
    STORAGE_BUCKET_NAME: ${STORAGE_BUCKET_NAME}
    STORAGE_ACCESS_KEY_ID: ${STORAGE_ACCESS_KEY_ID}
    STORAGE_SECRET_ACCESS_KEY: ${STORAGE_SECRET_ACCESS_KEY}
    STORAGE_ENDPOINT: ${STORAGE_ENDPOINT}
    STORAGE_FORCE_PATH_STYLE: ${STORAGE_FORCE_PATH_STYLE:-true}

    # --- Regras de ignorar mensagens ---
    IGNORE_GROUP_MESSAGES: ${IGNORE_GROUP_MESSAGES:-true}
    IGNORE_OWN_MESSAGES: ${IGNORE_OWN_MESSAGES:-true}
    IGNORE_YOURSELF_MESSAGES: ${IGNORE_YOURSELF_MESSAGES:-true}
    IGNORE_BROADCAST_STATUSES: ${IGNORE_BROADCAST_STATUSES:-true}
    IGNORE_STATUS_MESSAGE: ${IGNORE_STATUS_MESSAGE:-true}
    IGNORE_BROADCAST_MESSAGES: ${IGNORE_BROADCAST_MESSAGES:-true}
    IGNORE_HISTORY_MESSAGES: ${IGNORE_HISTORY_MESSAGES:-true}

    # --- Envio / comportamento extra ---
    SEND_CONNECTION_STATUS: ${SEND_CONNECTION_STATUS:-false}
    SEND_REACTION_AS_REPLY: ${SEND_REACTION_AS_REPLY:-false}
    SEND_PROFILE_PICTURE: ${SEND_PROFILE_PICTURE:-false}

    # --- Delays (ms) ---
    UNOAPI_DELAY_AFTER_FIRST_MESSAGE_WEBHOOK_MS: ${UNOAPI_DELAY_AFTER_FIRST_MESSAGE_WEBHOOK_MS:-1000}
    UNOAPI_DELAY_AFTER_FIRST_MESSAGE_MS: ${UNOAPI_DELAY_AFTER_FIRST_MESSAGE_MS:-1000}
    UNOAPI_DELAY_BETWEEN_MESSAGES_MS: ${UNOAPI_DELAY_BETWEEN_MESSAGES_MS:-1000}

    # --- Webhook / auth ---
    WEBHOOK_URL: ${WEBHOOK_URL}
    WEBHOOK_TOKEN: ${WEBHOOK_TOKEN}
    WEBHOOK_HEADER: ${WEBHOOK_HEADER}
    UNOAPI_AUTH_TOKEN: ${UNOAPI_AUTH_TOKEN}

    # --- Locale / templates ---
    DEFAULT_LOCALE: ${DEFAULT_LOCALE:-pt_BR}
    ONLY_HELLO_TEMPLATE: ${ONLY_HELLO_TEMPLATE:-true}

    # --- Limpeza / sessão ---
    CLEAN_CONFIG_ON_DISCONNECT: ${CLEAN_CONFIG_ON_DISCONNECT:-true}
    CONFIG_SESSION_PHONE_CLIENT: ${CONFIG_SESSION_PHONE_CLIENT:-IA Result}

    # --- Outros ---
    LOG_LEVEL: ${LOG_LEVEL:-debug}
    UNO_LOG_LEVEL: ${UNO_LOG_LEVEL:-debug}
    REJECT_CALLS: ${REJECT_CALLS:-''}
    REJECT_CALLS_WEBHOOK: ${REJECT_CALLS_WEBHOOK:-''}
    WEBHOOK_SEND_NEW_MESSAGES: ${WEBHOOK_SEND_NEW_MESSAGES:-false}
    NOTIFY_FAILED_MESSAGES: ${NOTIFY_FAILED_MESSAGES:-false}
    UNOAPI_QUEUE_NAME: ${UNOAPI_QUEUE_NAME:-iaresult}
    CONNECTING_TIMEOUT_MS: ${CONNECTING_TIMEOUT_MS:-180000}
    WHATSAPP_VERSION: '[2, 3000, 1028395461]'
    
  restart: 'no'

services:
  web:
    <<: *base
    entrypoint: yarn web
    restart: always
    ports:
      - "9876:9876"
    deploy:
      resources:
        limits:
          cpus: '5.80'
          memory: 12256M
        reservations:
          cpus: '5.85'
          memory: 1128M

  broker:
    <<: *base
    entrypoint: yarn broker
    restart: always
    deploy:
      resources:
        limits:
          cpus: '5.50'
          memory: 12256M
        reservations:
          cpus: '5.25'
          memory: 12128M

  bridge:
    <<: *base
    entrypoint: yarn bridge
    restart: always
    deploy:
      resources:
        limits:
          cpus: '5.50'
          memory: 12256M
        reservations:
          cpus: '5.95'
          memory: 12128M

networks:
  redis:
    external: true
  rabbitmq:
    external: true
  minio:
    external: true
```

#### No Portainer:

1. **Stacks** → Sua stack (ou **Add stack** se for nova)
2. Cole o YAML acima
3. Configure as variáveis de ambiente (`.env`)
4. Marque **✅ Pull latest image version**
5. **Deploy the stack**

---

## 🔄 Atualizações Futuras

Sempre que você fizer mudanças no código:

### Opção 1: Script Automático (Recomendado)

```powershell
.\deploy.ps1
```

### Opção 2: Manual

```powershell
git add .
git commit -m "Descrição da mudança"
git push origin main
```

Depois:
1. Aguarde o build no GitHub Actions (2-5 min)
2. No Portainer → **Update the stack** → **Pull and redeploy**

---

## 🔐 Se o Repositório for Privado

### Criar Personal Access Token

1. GitHub → **Settings** → **Developer settings** → **Personal access tokens** → **Tokens (classic)**
2. **Generate new token (classic)**
3. Permissões:
   - ✅ `read:packages`
   - ✅ `write:packages`
4. Copie o token

### Configurar no Portainer

1. **Registries** → **Add registry**
2. Configuração:
   - **Name**: `GitHub Container Registry`
   - **Registry URL**: `ghcr.io`
   - **Username**: `Bluebytedev` (seu usuário GitHub)
   - **Password**: Cole o token gerado
3. **Add registry**

---

## 📦 Versionamento (Opcional)

Para criar versões específicas:

```powershell
git tag v2.4.2
git push origin v2.4.2
```

Isso criará:
- `ghcr.io/bluebytedev/uno:latest`
- `ghcr.io/bluebytedev/uno:v2.4.2`
- `ghcr.io/bluebytedev/uno:2.4.2`
- `ghcr.io/bluebytedev/uno:2.4`
- `ghcr.io/bluebytedev/uno:2`

Para usar versão específica na stack:
```yaml
image: ghcr.io/bluebytedev/uno:v2.4.2
```

---

## 🐛 Troubleshooting

### ❌ Erro: "permission denied" no GitHub Actions

**Solução:**
1. GitHub → Repositório → **Settings**
2. **Actions** → **General**
3. **Workflow permissions** → **Read and write permissions**
4. Salvar

### ❌ Erro: "failed to pull image" no Portainer

**Solução 1 - Repositório Público:**
1. Verifique se o package está público em `https://github.com/Bluebytedev/uno/packages`

**Solução 2 - Repositório Privado:**
1. Configure o Registry no Portainer (veja seção acima)

### ❌ Imagem não atualiza no Portainer

**Solução:**
1. Sempre marque **"Pull latest image version"** ao atualizar
2. Ou force o pull manual:
   ```powershell
   docker pull ghcr.io/bluebytedev/uno:latest
   ```

---

## 🎯 Resumo do Fluxo

```
1. Você faz mudanças no código
         ↓
2. Executa: .\deploy.ps1
         ↓
3. GitHub Actions faz build automático
         ↓
4. Imagem publicada em ghcr.io/bluebytedev/uno:latest
         ↓
5. Portainer → Pull and redeploy
         ↓
6. ✅ Aplicação atualizada!
```

---

## 📚 Links Úteis

- **GitHub Actions**: https://github.com/Bluebytedev/uno/actions
- **Packages**: https://github.com/Bluebytedev/uno/packages
- **Documentação Baileys v7**: `ATUALIZACAO_BAILEYS_V7.md`
- **Setup Completo**: `DOCKER_GITHUB_SETUP.md`

---

## ✅ Checklist Inicial

- [ ] Executar `.\deploy.ps1`
- [ ] Verificar build no GitHub Actions
- [ ] Configurar permissões do package (público/privado)
- [ ] Atualizar stack no Portainer com nova imagem
- [ ] Testar conexão WhatsApp
- [ ] Verificar logs dos containers

**Pronto! Agora você tem deploy automático configurado! 🎉**
