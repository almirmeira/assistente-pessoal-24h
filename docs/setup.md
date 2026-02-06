# Guia de Configuração do OpenClaw

Este documento detalha o processo completo de configuração do OpenClaw para o projeto Assistente Pessoal 24h.

## Pré-requisitos

- Servidor Ubuntu 24.04 com acesso SSH
- Conta na Anthropic com API Key
- Node.js v22+ instalado no servidor

## Passo 1: Atualizar Node.js

O OpenClaw requer Node.js v22+. Para atualizar:

```bash
# Instalar nvm (Node Version Manager)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

# Recarregar shell
source ~/.bashrc

# Instalar Node.js 22
nvm install 22
nvm use 22
nvm alias default 22

# Verificar versão
node --version  # Deve mostrar v22.x.x
```

## Passo 2: Obter API Key da Anthropic

1. Acesse [console.anthropic.com](https://console.anthropic.com)
2. Faça login ou crie uma conta
3. Vá em **API Keys**
4. Clique em **Create Key**
5. Copie a chave (formato: `sk-ant-api03-...`)

## Passo 3: Configurar OpenClaw

### Parar containers existentes

```bash
cd /home/almir/openclaw
docker compose down
```

### Executar setup

```bash
# Se instalado via npm global
openclaw setup

# Ou via docker
docker run -it --rm \
  -v ~/.openclaw:/home/node/.openclaw \
  openclaw:local \
  node dist/index.js setup
```

### Configurar variáveis de ambiente

Edite `/home/almir/openclaw/.env`:

```env
# Diretórios
OPENCLAW_CONFIG_DIR=/root/.openclaw
OPENCLAW_WORKSPACE_DIR=/root/.openclaw/workspace

# Gateway
OPENCLAW_GATEWAY_TOKEN=<seu-token-gerado>
OPENCLAW_GATEWAY_PORT=18789
OPENCLAW_BRIDGE_PORT=18790
OPENCLAW_GATEWAY_BIND=lan

# Anthropic API
ANTHROPIC_API_KEY=sk-ant-api03-SUA-CHAVE-AQUI

# Docker
OPENCLAW_IMAGE=openclaw:local
```

## Passo 4: Configurar Gateway

Crie/edite `~/.openclaw/openclaw.json`:

```json
{
  "gateway": {
    "mode": "local",
    "port": 18789,
    "bind": "0.0.0.0"
  },
  "model": {
    "provider": "anthropic",
    "model": "claude-sonnet-4-20250514"
  },
  "channels": {
    "whatsapp": {
      "enabled": false
    },
    "telegram": {
      "enabled": false
    }
  }
}
```

## Passo 5: Iniciar Serviços

```bash
cd /home/almir/openclaw
docker compose up -d

# Verificar status
docker compose ps
docker logs openclaw-openclaw-gateway-1 --tail 20
```

## Passo 6: Testar Conexão

```bash
# Testar gateway
curl http://localhost:18789/health

# Ou do notebook remoto
curl http://192.168.1.26:18789/health
```

## Solução de Problemas

### Gateway reiniciando em loop

**Sintoma**: `docker logs` mostra "Missing config"

**Solução**:
1. Execute `openclaw setup`
2. Ou crie `~/.openclaw/openclaw.json` com `gateway.mode = "local"`

### Erro de API Key

**Sintoma**: Erros de autenticação

**Solução**:
1. Verifique se `ANTHROPIC_API_KEY` está no `.env`
2. Confirme que a chave é válida em console.anthropic.com

### Porta já em uso

**Sintoma**: "Port 18789 already in use"

**Solução**:
```bash
# Encontrar processo
lsof -i :18789

# Matar processo
kill -9 <PID>
```

## Comandos Úteis

```bash
# Status dos containers
docker compose ps

# Logs em tempo real
docker compose logs -f

# Reiniciar gateway
docker compose restart openclaw-gateway

# Reconstruir imagem
docker compose build --no-cache

# Limpar tudo e recomeçar
docker compose down -v
docker compose up -d --build
```

## Próximos Passos

Após configuração bem-sucedida:
1. Configure integrações (ver `integrações.md`)
2. Configure skills personalizadas
3. Teste comandos básicos via CLI
