# Hardening do Servidor OpenClaw

Documentação das configurações de segurança aplicadas no servidor 192.168.1.26.

**Data:** 2026-02-07
**Baseado em:** CIS Benchmarks Ubuntu 24.04, OWASP Top 10 Web/API

---

## Resumo das Configurações

| Categoria | Status | Descrição |
|-----------|--------|-----------|
| Firewall UFW | ✅ Ativo | Regras restritivas configuradas |
| SSH Hardening | ✅ Aplicado | Criptografia forte, timeouts |
| Kernel Hardening | ✅ Aplicado | Parâmetros de rede seguros |
| Fail2ban | ✅ Ativo | Proteção SSH e rate limiting |
| Auditd | ✅ Ativo | Monitoramento de arquivos críticos |
| Caddy Headers | ✅ Aplicado | Headers OWASP de segurança |
| Serviços | ✅ Desabilitados | CUPS, Avahi, ModemManager |

---

## 1. Firewall UFW

**Arquivo:** Sistema (ufw)

```bash
# Status
ufw status verbose
```

**Regras configuradas:**
- `22/tcp` - SSH (qualquer origem)
- `80/tcp` - HTTP (qualquer origem - redirect para HTTPS)
- `443/tcp` - HTTPS (qualquer origem)
- `18789/tcp` - OpenClaw Gateway (apenas 192.168.1.0/24)
- `18790/tcp` - OpenClaw Bridge (apenas 192.168.1.0/24)
- `172.16.0.0/12` - Redes Docker internas

**Política padrão:**
- Incoming: DENY
- Outgoing: ALLOW

---

## 2. SSH Hardening (CIS 5.2.x)

**Arquivo:** `/etc/ssh/sshd_config.d/99-hardening.conf`

```
Protocol 2
PermitRootLogin yes                    # Mantido conforme solicitado
MaxAuthTries 4
MaxSessions 10
PubkeyAuthentication yes
PasswordAuthentication yes
PermitEmptyPasswords no
X11Forwarding no
AllowTcpForwarding no
AllowAgentForwarding no
ClientAliveInterval 300
ClientAliveCountMax 3
LoginGraceTime 60
Banner /etc/issue.net

# Criptografia forte
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com
KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org
```

---

## 3. Kernel Hardening (CIS 3.x)

**Arquivo:** `/etc/sysctl.d/99-cis-hardening.conf`

```
# Desabilitar redirects ICMP
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.all.accept_redirects = 0

# Desabilitar source routing
net.ipv4.conf.all.accept_source_route = 0

# Habilitar SYN cookies (proteção DoS)
net.ipv4.tcp_syncookies = 1

# Log pacotes suspeitos
net.ipv4.conf.all.log_martians = 1

# Ignorar broadcasts ICMP
net.ipv4.icmp_echo_ignore_broadcasts = 1

# Reverse path filtering
net.ipv4.conf.all.rp_filter = 1

# Restringir dmesg e ponteiros kernel
kernel.dmesg_restrict = 1
kernel.kptr_restrict = 2

# ASLR habilitado
kernel.randomize_va_space = 2
```

---

## 4. Fail2ban

**Arquivo:** `/etc/fail2ban/jail.local`

### Jails Ativos:

| Jail | maxretry | findtime | bantime | Descrição |
|------|----------|----------|---------|-----------|
| sshd | 3 | 600s | 3600s | Proteção força bruta SSH |
| caddy-badbots | 10 | 60s | 3600s | Bloqueia bots maliciosos |
| caddy-ratelimit | 100 | 60s | 600s | Rate limiting HTTP |

**Comandos úteis:**
```bash
fail2ban-client status
fail2ban-client status sshd
fail2ban-client unban <IP>
```

---

## 5. Auditoria (CIS 4.1.x)

**Arquivo:** `/etc/audit/rules.d/99-cis-hardening.rules`

**Arquivos monitorados:**
- `/etc/passwd`, `/etc/shadow`, `/etc/group` - Alterações de usuários
- `/etc/sudoers`, `/etc/sudoers.d/` - Alterações de privilégios
- `/etc/ssh/sshd_config` - Configuração SSH
- `/var/log/lastlog` - Logins
- `/usr/bin/docker`, `/var/lib/docker` - Docker
- `/etc/crontab`, `/etc/cron.d/` - Cron jobs
- `/etc/hosts` - Configuração de rede

**Comandos úteis:**
```bash
ausearch -k identity       # Buscar alterações de usuários
ausearch -k sshd_config    # Buscar alterações SSH
aureport --summary         # Relatório resumido
```

---

## 6. Caddy - Headers de Segurança (OWASP)

**Arquivo:** `/etc/caddy/Caddyfile`

### Headers Aplicados:

| Header | Valor | Proteção OWASP |
|--------|-------|----------------|
| X-Content-Type-Options | nosniff | MIME Sniffing |
| X-Frame-Options | DENY | Clickjacking |
| X-XSS-Protection | 1; mode=block | XSS Reflected |
| Strict-Transport-Security | max-age=31536000 | MITM |
| Content-Security-Policy | default-src 'self'... | XSS, Injection |
| Referrer-Policy | strict-origin-when-cross-origin | Information Leakage |
| Permissions-Policy | geolocation=(), ... | Feature Policy |
| Cache-Control | no-store, no-cache | Sensitive Data |

### Paths Bloqueados:
- `/.env`, `/.git*`, `/.svn*` - Arquivos de configuração
- `/wp-*`, `/phpmyadmin*` - Paths de CMS/admin comuns
- `/*.sql`, `/*.bak`, `/*.log` - Arquivos sensíveis

### Métodos HTTP Bloqueados:
- TRACE, TRACK, OPTIONS

---

## 7. Serviços Desabilitados

Os seguintes serviços foram desabilitados e mascarados:

- `cups` / `cups-browsed` - Impressão (não necessário)
- `avahi-daemon` - mDNS (não necessário)
- `ModemManager` - Modems (não necessário)
- `gnome-remote-desktop` - Desktop remoto (risco de segurança)

---

## Verificação de Status

```bash
# Firewall
ufw status verbose

# SSH
sshd -T | grep -E "permitrootlogin|passwordauth|x11forwarding"

# Fail2ban
fail2ban-client status

# Auditd
systemctl status auditd

# Caddy
curl -sI https://localhost | grep -iE "x-frame|x-content|strict"

# Kernel params
sysctl net.ipv4.tcp_syncookies net.ipv4.conf.all.rp_filter
```

---

## Manutenção

### Logs para Monitorar:
- `/var/log/auth.log` - Autenticação SSH
- `/var/log/caddy/access.log` - Requisições HTTP
- `/var/log/audit/audit.log` - Eventos de auditoria
- `/var/log/fail2ban.log` - Banimentos

### Atualizações:
```bash
# Atualizar sistema
apt update && apt upgrade -y

# Reiniciar serviços após atualizações
systemctl restart ssh caddy fail2ban auditd
```

---

## Notas Importantes

1. **SSH Root Login mantido** conforme solicitação do usuário
2. **IP_Forward habilitado** necessário para Docker
3. **Certificado HTTPS auto-assinado** - considerar Let's Encrypt para produção
4. **OpenClaw acessível apenas da rede local** (192.168.1.0/24)

---

*Documentação gerada em 2026-02-07*
