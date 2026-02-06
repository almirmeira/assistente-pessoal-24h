#!/bin/bash
# Script para verificar status do servidor OpenClaw
# Uso: ./check-status.sh

SERVER_IP="192.168.1.26"
SERVER_USER="root"
GATEWAY_PORT="18789"

echo "=========================================="
echo "  Verificação de Status - OpenClaw"
echo "  Servidor: $SERVER_IP"
echo "  Data: $(date)"
echo "=========================================="
echo ""

# Verificar conectividade
echo "[1/5] Testando conectividade..."
if ping -c 1 -W 2 $SERVER_IP > /dev/null 2>&1; then
    echo "      ✓ Servidor acessível"
else
    echo "      ✗ Servidor inacessível"
    exit 1
fi

# Verificar SSH
echo ""
echo "[2/5] Testando SSH..."
if ssh -o ConnectTimeout=5 -o BatchMode=yes $SERVER_USER@$SERVER_IP "echo ok" > /dev/null 2>&1; then
    echo "      ✓ SSH funcionando"
else
    echo "      ✗ SSH não disponível"
    exit 1
fi

# Verificar Docker
echo ""
echo "[3/5] Verificando containers Docker..."
ssh $SERVER_USER@$SERVER_IP "docker ps --format 'table {{.Names}}\t{{.Status}}' | grep openclaw" 2>/dev/null
echo ""

# Verificar Gateway
echo "[4/5] Testando Gateway (porta $GATEWAY_PORT)..."
if curl -s --connect-timeout 5 "http://$SERVER_IP:$GATEWAY_PORT/health" > /dev/null 2>&1; then
    echo "      ✓ Gateway respondendo"
else
    echo "      ✗ Gateway não responde"
    echo "      Verificando logs..."
    ssh $SERVER_USER@$SERVER_IP "docker logs openclaw-openclaw-gateway-1 --tail 5" 2>/dev/null
fi

# Verificar recursos
echo ""
echo "[5/5] Recursos do servidor..."
ssh $SERVER_USER@$SERVER_IP "echo '      CPU: ' \$(top -bn1 | grep 'Cpu(s)' | awk '{print \$2}')% && echo '      RAM: ' \$(free -h | awk '/^Mem:/ {print \$3 \"/\" \$2}') && echo '      Disco: ' \$(df -h / | awk 'NR==2 {print \$3 \"/\" \$2}')" 2>/dev/null

echo ""
echo "=========================================="
echo "  Verificação concluída"
echo "=========================================="
