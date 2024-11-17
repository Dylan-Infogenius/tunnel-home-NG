#!/usr/bin/env bash

CONFIG_PATH=/data/options.json

# Lire la configuration
SERVER_PUBLIC_KEY=$(jq --raw-output '.server_public_key' $CONFIG_PATH)
ENDPOINT=$(jq --raw-output '.endpoint' $CONFIG_PATH)
CLIENT_IP=$(jq --raw-output '.client_ip' $CONFIG_PATH)
SERVER_IP=$(jq --raw-output '.server_ip' $CONFIG_PATH)

# Créer un fichier wg0.conf
cat <<EOF > /etc/wireguard/wg0.conf
[Interface]
PrivateKey = (clé privée générée pour le client)
Address = $CLIENT_IP/30

[Peer]
PublicKey = $SERVER_PUBLIC_KEY
Endpoint = $ENDPOINT
AllowedIPs = $CLIENT_IP/30
PersistentKeepalive = 25
EOF

# Démarrer WireGuard
wg-quick up wg0
tail -f /dev/null
