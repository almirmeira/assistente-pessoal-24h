#!/bin/bash
# Script para criar túnel SSH para o OpenClaw
# Uso: ./tunnel-openclaw.sh

SERVER_IP="192.168.1.26"
SERVER_USER="root"
LOCAL_PORT="18789"
REMOTE_PORT="18789"

echo "=========================================="
echo "  Túnel SSH para OpenClaw"
echo "=========================================="
echo ""
echo "Criando túnel: localhost:$LOCAL_PORT -> $SERVER_IP:$REMOTE_PORT"
echo ""
TOKEN="6d2ad2490dbfe0f221c6a425fbdd1c69e94f7f77892faa06"

echo "Após conectar, acesse no navegador:"
echo "  http://localhost:$LOCAL_PORT/?token=$TOKEN"
echo ""
echo "Pressione Ctrl+C para encerrar o túnel."
echo "=========================================="
echo ""

ssh -N -L $LOCAL_PORT:localhost:$REMOTE_PORT $SERVER_USER@$SERVER_IP
