#!/usr/bin/env bash

INSTALL_FLAG="/data/installed"

# Vérifier si le hook d'installation doit être exécuté
if [ ! -f "$INSTALL_FLAG" ]; then
    echo "$(date +%d/%m/%y\ %H:%M:%S) Exécution du script d'installation..."
    /install.sh
    if [ $? -eq 0 ]; then
        touch "$INSTALL_FLAG"
    else
        echo "$(date +%d/%m/%y\ %H:%M:%S) Erreur lors de l'installation. Arrêt de l'add-on."
        exit 1
    fi
fi

echo "$(date +%d/%m/%y\ %H:%M:%S) Démarrage de l'add-on..."

CONFIG_PATH=/data/options.json

# Chemin des fichiers persistants
PRIVATE_KEY_FILE="/data/client_private.key"
SERVER_PUBLIC_KEY_FILE="/data/server_public.key"
DATA_FILE="/data/data.json"

# Vérifier si l'installation a été effectuée
if [ ! -f "$PRIVATE_KEY_FILE" ] || [ ! -f "$SERVER_PUBLIC_KEY_FILE" ]; then
    echo "$(date +%d/%m/%y\ %H:%M:%S) Erreur : L'installation n'a pas été correctement effectuée. Exécutez à nouveau l'installation."
    exit 1
fi

# Charger les informations nécessaires
CLIENT_PRIVATE_KEY=$(cat "$PRIVATE_KEY_FILE")
SERVER_PUBLIC_KEY=$(cat "$SERVER_PUBLIC_KEY_FILE")
ENDPOINT=$(jq --raw-output '.endpoint' "$DATA_FILE")
NETWORK=$(jq --raw-output '.network' "$DATA_FILE")
CLIENT_IP=$(jq --raw-output '.client_ip' "$DATA_FILE")

# Créer la configuration WireGuard
cat <<EOF > /etc/wireguard/wg0.conf
[Interface]
PrivateKey = $CLIENT_PRIVATE_KEY
Address = $CLIENT_IP/30

[Peer]
PublicKey = $SERVER_PUBLIC_KEY
Endpoint = $ENDPOINT
AllowedIPs = $NETWORK
PersistentKeepalive = 25
EOF

# Démarrer WireGuard
wg-quick up wg0
tail -f /dev/null