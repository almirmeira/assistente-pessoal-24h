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
TOKEN="961044840b69cab1da9ea9bf8e4e301b8ac9f1b63bd816b8"
# Atualizado em: 2026-02-06 18:08 - FUNCIONANDO

echo "Após conectar, acesse no navegador:"
echo "  http://localhost:$LOCAL_PORT/?token=$TOKEN"
echo ""
echo "Pressione Ctrl+C para encerrar o túnel."
echo "=========================================="
echo ""

ssh -N -L $LOCAL_PORT:localhost:$REMOTE_PORT $SERVER_USER@$SERVER_IP
