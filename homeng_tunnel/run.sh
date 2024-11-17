#!/usr/bin/env bash

CONFIG_PATH=/data/options.json

# Lire la configuration
SERVER_PUBLIC_KEY=$(jq --raw-output '.server_public_key' $CONFIG_PATH)
ENDPOINT=$(jq --raw-output '.endpoint' $CONFIG_PATH)
CLIENT_IP=$(jq --raw-output '.client_ip' $CONFIG_PATH)
SERVER_IP=$(jq --raw-output '.server_ip' $CONFIG_PATH)

# Chemin pour stocker les clés
PRIVATE_KEY_FILE="/data/client_private.key"
PUBLIC_KEY_FILE="/data/client_public.key"

# Vérifier si les clés existent déjà
if [ -f "$PRIVATE_KEY_FILE" ] && [ -f "$PUBLIC_KEY_FILE" ]; then
    echo "Chargement des clés WireGuard existantes..."
    CLIENT_PRIVATE_KEY=$(cat "$PRIVATE_KEY_FILE")
    CLIENT_PUBLIC_KEY=$(cat "$PUBLIC_KEY_FILE")
    echo "$CLIENT_PUBLIC_KEY"
else
    echo "Génération de nouvelles clés WireGuard..."
    CLIENT_PRIVATE_KEY=$(wg genkey)
    CLIENT_PUBLIC_KEY=$(echo "$CLIENT_PRIVATE_KEY" | wg pubkey)

    # Sauvegarder les clés dans /data
    echo "$CLIENT_PRIVATE_KEY" > "$PRIVATE_KEY_FILE"
    echo "$CLIENT_PUBLIC_KEY" > "$PUBLIC_KEY_FILE"
    echo "$CLIENT_PUBLIC_KEY"
    echo "Clés générées et sauvegardées."
fi

# Créer la configuration WireGuard
cat <<EOF > /etc/wireguard/wg0.conf
[Interface]
PrivateKey = $CLIENT_PRIVATE_KEY
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