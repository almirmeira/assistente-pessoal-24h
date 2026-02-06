# Assistente Pessoal 24h

Projeto de automação pessoal utilizando OpenClaw como plataforma principal de agente de IA.

## Arquitetura

```
┌─────────────────────────────────────────────────────────────────┐
│                     REDE LOCAL (192.168.1.x)                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────────┐      ┌─────────────────────────────┐  │
│  │  Notebook Gestão    │      │  Servidor OpenClaw          │  │
│  │  (Este computador)  │ SSH  │  IP: 192.168.1.26           │  │
│  │                     │─────>│                             │  │
│  │  - Documentação     │      │  - OpenClaw (Docker)        │  │
│  │  - Claude Code      │      │  - Gateway :18789           │  │
│  │  - Scripts          │      │  - Bridge :18790            │  │
│  └─────────────────────┘      └─────────────────────────────┘  │
│                                          │                      │
└──────────────────────────────────────────│──────────────────────┘
                                           │
                                           ▼
                          ┌────────────────────────────────┐
                          │      INTEGRAÇÕES EXTERNAS      │
                          ├────────────────────────────────┤
                          │  WhatsApp    │  LinkedIn       │
                          │  Instagram   │  Facebook       │
                          │  GitHub      │  Corretora      │
                          └────────────────────────────────┘
```

## Requisitos do Sistema

| Componente | Servidor OpenClaw | Notebook Gestão |
|------------|-------------------|-----------------|
| SO | Ubuntu 24.04 | Ubuntu 24.04 |
| CPU | - | Intel i5 |
| RAM | 4GB+ recomendado | 8GB |
| Disco | 20GB+ | 500GB |
| Node.js | v22+ | v18+ |

## Servidor OpenClaw

- **IP**: 192.168.1.26
- **Usuário SSH**: root
- **Localização OpenClaw**: `/home/almir/openclaw/`
- **Gateway**: porta 18789
- **Bridge**: porta 18790

## Configuração Inicial

### 1. Conectar ao servidor

```bash
ssh root@192.168.1.26
```

### 2. Configurar OpenClaw

```bash
cd /home/almir/openclaw
docker compose down
openclaw setup
```

### 3. Acessar Interface Web

**Via túnel SSH (recomendado):**
```bash
# No notebook local, execute:
ssh -N -L 18789:localhost:18789 root@192.168.1.26

# Depois acesse no navegador:
# http://localhost:18789/?token=SEU_TOKEN
```

**Via HTTPS direto:**
```
https://192.168.1.26/?token=SEU_TOKEN
```

### 4. Token de Acesso

O token atual está em `/root/.openclaw/openclaw.json` no servidor.

Para obter o token:
```bash
ssh root@192.168.1.26 "grep -A2 '\"auth\"' /root/.openclaw/openclaw.json"
```

## Integrações Planejadas

### Fase 1 - Fundação
- [x] Instalação OpenClaw
- [ ] Configuração Gateway
- [ ] Integração Claude Code

### Fase 2 - Comunicação
- [ ] WhatsApp Business API
- [ ] Telegram Bot

### Fase 3 - Redes Sociais
- [ ] LinkedIn (API Oficial)
- [ ] Instagram (Meta Business)
- [ ] Facebook (Meta Business)

### Fase 4 - Agente de Investimentos
- [ ] Integração com corretora
- [ ] Análise de mercado
- [ ] Execução automatizada

## Estrutura do Projeto

```
assistente-pessoal-24h/
├── README.md           # Este arquivo
├── docs/               # Documentação detalhada
│   ├── setup.md        # Guia de instalação
│   ├── integrações.md  # Guia de integrações
│   └── investimentos.md # Documentação do agente financeiro
├── config/             # Arquivos de configuração
│   └── openclaw.json   # Config do OpenClaw
├── scripts/            # Scripts de automação
│   └── check-status.sh # Verificar status do servidor
└── integrações/        # Configs específicas por integração
    ├── whatsapp/
    ├── linkedin/
    └── investimentos/
```

## Avisos Importantes

### Segurança
- Nunca compartilhe chaves de API em repositórios públicos
- Use variáveis de ambiente ou arquivos `.env` (não versionados)
- Configure autenticação SSH por chave, não por senha

### Investimentos Automatizados
- Operações automatizadas envolvem riscos financeiros significativos
- Consulte um profissional antes de operar com dinheiro real
- Sempre teste em ambiente sandbox/simulado primeiro
- Mantenha limites de perda configurados

### Redes Sociais
- Automação excessiva pode violar termos de serviço
- Use APIs oficiais sempre que disponíveis
- Respeite rate limits e políticas de uso

## Contato

- **GitHub**: [@almirmeira](https://github.com/almirmeira)

---

*Projeto iniciado em: 06 de Fevereiro de 2026*
