# 🐳 Setup Docker com GitHub Container Registry

Este guia explica como configurar o build automático da imagem Docker customizada do UnoAPI usando GitHub Actions.

## 📋 Pré-requisitos

1. Repositório no GitHub: `https://github.com/Bluebytedev/uno`
2. Portainer configurado
3. Redes Docker criadas: `redis`, `rabbitmq`, `minio`

## 🚀 Passo a Passo

### 1. Fazer Push do Código para o GitHub

```bash
cd c:\Users\developer\Desktop\UNOAPI\unoapi-cloud-2.4.1\uno
git init
git add .
git commit -m "Initial commit - UnoAPI Cloud 2.4.1 com Baileys v7"
git branch -M main
git remote add origin https://github.com/Bluebytedev/uno.git
git push -u origin main
```

### 2. Verificar o Build Automático

Após o push, o GitHub Actions irá:
- ✅ Detectar o push na branch `main`
- ✅ Executar o workflow `.github/workflows/docker-build.yml`
- ✅ Fazer build da imagem Docker
- ✅ Publicar em `ghcr.io/bluebytedev/uno:latest`

Acompanhe em: `https://github.com/Bluebytedev/uno/actions`

### 3. Configurar Permissões do Package (Primeira Vez)

1. Acesse: `https://github.com/Bluebytedev/uno/packages`
2. Clique no package `uno`
3. **Package settings** → **Change visibility** → **Public** (se quiser público)
4. Ou mantenha privado e configure credenciais no Portainer

### 4. Atualizar Stack no Portainer

Use a stack abaixo no Portainer:

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

## 🔐 Se o Repositório for Privado

### Criar Personal Access Token (PAT)

1. GitHub → **Settings** → **Developer settings** → **Personal access tokens** → **Tokens (classic)**
2. **Generate new token (classic)**
3. Permissões necessárias:
   - ✅ `read:packages`
   - ✅ `write:packages` (se for fazer push)
4. Copie o token gerado

### Configurar Registry no Portainer

1. Portainer → **Registries** → **Add registry**
2. Configuração:
   - **Name**: GitHub Container Registry
   - **Registry URL**: `ghcr.io`
   - **Username**: seu usuário GitHub (ex: `Bluebytedev`)
   - **Password**: Cole o Personal Access Token

3. Salvar

Agora o Portainer conseguirá baixar imagens privadas do GHCR.

## 🔄 Atualizar a Imagem

### Opção 1: Automático (Recomendado)
Qualquer push na branch `main` irá gerar uma nova imagem automaticamente.

```bash
git add .
git commit -m "Atualização XYZ"
git push origin main
```

### Opção 2: Manual via Tag
Criar uma tag de versão:

```bash
git tag v2.4.2
git push origin v2.4.2
```

Isso criará as imagens:
- `ghcr.io/bluebytedev/uno:latest`
- `ghcr.io/bluebytedev/uno:v2.4.2`
- `ghcr.io/bluebytedev/uno:2.4.2`
- `ghcr.io/bluebytedev/uno:2.4`
- `ghcr.io/bluebytedev/uno:2`

### Opção 3: Executar Workflow Manualmente
1. GitHub → **Actions**
2. Selecione **Build and Push Docker Image**
3. **Run workflow** → Escolha a branch → **Run workflow**

## 📦 Atualizar Stack no Portainer

Após nova imagem ser publicada:

1. Portainer → **Stacks** → Sua stack
2. **Editor** → Clique em **Pull and redeploy**
3. Ou use o botão **Update the stack**

Isso irá:
- ✅ Baixar a nova imagem `latest`
- ✅ Recriar os containers
- ✅ Aplicar as mudanças

## 🎯 Vantagens desta Configuração

✅ **Build automático** a cada commit  
✅ **Versionamento** com tags semânticas  
✅ **Cache otimizado** (builds mais rápidos)  
✅ **Gratuito** para repositórios públicos  
✅ **Rollback fácil** usando tags antigas  
✅ **CI/CD completo** integrado ao GitHub  

## 🐛 Troubleshooting

### Erro: "permission denied"
- Verifique se o repositório tem permissão para criar packages
- Settings → Actions → General → Workflow permissions → **Read and write permissions**

### Erro: "failed to solve: failed to fetch"
- Verifique se o Dockerfile está na raiz do repositório
- Confirme que todas as dependências estão corretas

### Imagem não atualiza no Portainer
```bash
# Force pull da nova imagem
docker pull ghcr.io/bluebytedev/uno:latest

# Ou no Portainer, marque "Re-pull image" ao atualizar a stack
```

## 📚 Recursos Adicionais

- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [GitHub Container Registry](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)
- [Docker Build Push Action](https://github.com/docker/build-push-action)
