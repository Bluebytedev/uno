# 🛠️ Solução do Erro de Build

## ❌ Problema Identificado

O build no GitHub Actions falhou com:
```
ERROR: failed to solve: process "/bin/sh -c yarn build" returned non-zero exit code: 138
```

**Causa:** Exit code 138 = **falta de memória** durante o build do TypeScript.

---

## ✅ Correção Aplicada

### 1. Dockerfile Otimizado

**Antes:**
```dockerfile
ENV NODE_ENV=development
RUN yarn
RUN yarn build
```

**Depois:**
```dockerfile
ENV NODE_ENV=development
ENV NODE_OPTIONS=--max-old-space-size=4096
RUN yarn install --frozen-lockfile --network-timeout 600000
RUN yarn build
```

**Melhorias:**
- ✅ Memória aumentada para 4GB (`NODE_OPTIONS`)
- ✅ Timeout de rede de 10 minutos (evita falhas de conexão)
- ✅ `--frozen-lockfile` garante versões exatas
- ✅ `--production` na etapa final (reduz tamanho)

### 2. GitHub Actions Otimizado

Adicionado `build-args` no workflow:
```yaml
build-args: |
  NODE_OPTIONS=--max-old-space-size=4096
```

---

## 🚀 Próximos Passos

### 1. Fazer Push

```powershell
git push origin main
```

### 2. Acompanhar Build

1. Acesse: https://github.com/Bluebytedev/uno/actions
2. Clique no workflow que está rodando
3. Aguarde finalizar (5-10 minutos)
4. Deve aparecer ✅ verde

### 3. Configurar Permissões (Primeira Vez)

Após build bem-sucedido:

1. Acesse: https://github.com/Bluebytedev/uno/packages
2. Clique no package **uno**
3. **Package settings** → **Change visibility** → **Public**
4. Salvar

### 4. Atualizar Portainer

Agora o Portainer conseguirá baixar a imagem:

```yaml
image: ghcr.io/bluebytedev/uno:latest
```

---

## 🔍 Verificar se Funcionou

### Teste Local (Opcional)

```powershell
# Testar build local
docker build -t uno-test .

# Se funcionar, a correção está ok
```

### Verificar Imagem Publicada

Após build no GitHub:

```powershell
# Tentar baixar a imagem
docker pull ghcr.io/bluebytedev/uno:latest
```

Se baixar sem erro = sucesso! 🎉

---

## 🐛 Se Ainda Falhar

### Erro Persiste no Build

Se o erro 138 continuar:

1. Verifique os logs completos no GitHub Actions
2. Pode ser necessário simplificar o build
3. Considere usar imagem base menor

### Erro de Permissão no Portainer

Se ainda der `denied`:

1. Confirme que o package está **público**
2. Ou configure Registry privado no Portainer:
   - **Registries** → **Add registry**
   - URL: `ghcr.io`
   - Username: seu GitHub
   - Password: Personal Access Token

---

## 📊 Comparação

| Antes | Depois |
|-------|--------|
| Memória padrão (~512MB) | 4GB garantidos |
| Timeout padrão (60s) | 600s (10min) |
| Build falhava | Build deve funcionar |
| Exit code 138 | Exit code 0 ✅ |

---

## 💡 Dica

Se você tem muitas dependências ou código grande, considere:

1. **Build em etapas** (já implementado no Dockerfile)
2. **Cache do GitHub Actions** (já configurado)
3. **Reduzir dependências** de desenvolvimento

---

## ✅ Checklist

- [x] Dockerfile otimizado
- [x] Workflow atualizado
- [x] Commit criado
- [ ] **VOCÊ: git push origin main**
- [ ] Aguardar build no GitHub
- [ ] Configurar package como público
- [ ] Testar pull no Portainer

**Agora é só fazer o push! 🚀**
