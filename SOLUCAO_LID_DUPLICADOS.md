# Solução para Problemas de @lid e Contatos Duplicados

## 🔍 O que é o problema do @lid?

O WhatsApp usa dois tipos de identificadores para contatos:

1. **JID Normal**: `5511999999999@s.whatsapp.net` (contato salvo)
2. **LID (Local ID)**: `lid:5511999999999@lid` (contato NÃO salvo)

### Quando ocorre?

- Quando alguém envia mensagem mas **não está salvo nos contatos**
- O WhatsApp cria um ID temporário local (`lid:`)
- Se depois o contato for salvo, pode criar **duplicação**

## ✅ Solução Implementada

### Arquivo Modificado
`src/store/make-in-memory-store.ts`

### O que foi feito?

Adicionada a função `mergeDuplicateContacts()` que:

1. **Detecta contatos com `lid:`**
   - Extrai o número de telefone do ID local
   - Procura por um contato com JID normal correspondente

2. **Mescla automaticamente**
   - Combina os dados dos dois contatos
   - Mantém apenas o JID normal
   - Remove o contato duplicado com `lid:`

3. **Funciona nos dois sentidos**
   - Se recebe `lid:` e existe JID normal → mescla
   - Se recebe JID normal e existe `lid:` → mescla

### Exemplo de Funcionamento

```
ANTES:
- lid:5511999999999@lid (nome: "João")
- 5511999999999@s.whatsapp.net (nome: "João Silva")

DEPOIS:
- 5511999999999@s.whatsapp.net (nome: "João Silva", dados mesclados)
```

## 🚀 Como Aplicar

### 1. Reiniciar o Serviço

```bash
# Se estiver usando Docker
docker-compose restart

# Ou se estiver rodando diretamente
npm run build
npm start
```

### 2. Verificar Logs

A função registra quando mescla contatos:

```
Merging duplicate contact with lid: { lidContact: 'lid:5511999999999@lid', normalContact: '5511999999999@s.whatsapp.net' }
```

## 📋 Benefícios

✅ **Elimina duplicação automática** de contatos  
✅ **Mantém histórico de mensagens** unificado  
✅ **Melhora performance** (menos contatos duplicados)  
✅ **Transparente** para o usuário final  
✅ **Funciona automaticamente** sem configuração

## 🔧 Configurações Adicionais

Não são necessárias configurações adicionais. A solução funciona automaticamente sempre que:

- Novos contatos são adicionados (`contacts.upsert`)
- Contatos são atualizados
- Mensagens são recebidas de contatos não salvos

## 📝 Notas Técnicas

### Quando a mesclagem acontece?

- Durante o `contactsUpsert()` - quando contatos são inseridos/atualizados
- Antes de salvar o contato no store
- De forma automática e transparente

### Prioridade de dados

Quando há conflito de dados:
- **JID Normal tem prioridade** sobre `lid:`
- Dados do `lid:` são preservados se não existirem no JID normal
- Nome, foto e outros atributos são mesclados

## ⚠️ Importante

- A solução **não afeta** contatos já existentes
- Apenas **previne novas duplicações**
- Para limpar duplicações antigas, seria necessário um script de migração

## 🐛 Troubleshooting

### Ainda vejo contatos duplicados?

1. Verifique se reiniciou o serviço
2. Contatos duplicados **antes** da atualização não são mesclados automaticamente
3. Novos contatos serão mesclados automaticamente

### Como limpar duplicações antigas?

Você pode criar um script para limpar manualmente ou aguardar que os contatos sejam atualizados naturalmente.

## 📊 Monitoramento

Para ver a mesclagem em ação, ative logs de debug:

```env
LOG_LEVEL=debug
```

Você verá mensagens como:
```
Merging duplicate contact with lid
Merging duplicate contact with normal JID
```
