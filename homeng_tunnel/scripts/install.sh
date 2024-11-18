#!/usr/bin/env bash

CONFIG_PATH=/data/options.json

# Lire les options depuis options.json
API_KEY=$(jq --raw-output '.api_key' "$CONFIG_PATH")

# Vérifier si l'API key est fournie
if [ -z "$API_KEY" ]; then
    echo "$(date +%d/%m/%y\ %H:%M:%S) Erreur : Une API key est requise pour communiquer avec l'API."
    exit 1
fi

# Générer les clés si elles n'existent pas déjà
PRIVATE_KEY_FILE="/data/client_private.key"
PUBLIC_KEY_FILE="/data/client_public.key"

if [ ! -f "$PRIVATE_KEY_FILE" ] || [ ! -f "$PUBLIC_KEY_FILE" ]; then
    echo "$(date +%d/%m/%y\ %H:%M:%S) Génération des clés WireGuard pour le client..."
    CLIENT_PRIVATE_KEY=$(wg genkey)
    CLIENT_PUBLIC_KEY=$(echo "$CLIENT_PRIVATE_KEY" | wg pubkey)

    # Sauvegarder les clés
    echo "$CLIENT_PRIVATE_KEY" > "$PRIVATE_KEY_FILE"
    echo "$CLIENT_PUBLIC_KEY" > "$PUBLIC_KEY_FILE"
    echo "$(date +%d/%m/%y\ %H:%M:%S) Clés générées et sauvegardées."
else
    # Charger les clés existantes
    echo "$(date +%d/%m/%y\ %H:%M:%S) Chargement des clés WireGuard existantes..."
    CLIENT_PUBLIC_KEY=$(cat "$PUBLIC_KEY_FILE")
fi

# Envoyer la clé publique au serveur et récupérer la configuration
echo "$(date +%d/%m/%y\ %H:%M:%S) Envoi de la clé publique au serveur..."
RESPONSE=$(curl -s -X POST "https://vpn01.home-ng.app/api/register" \
    -H "Authorization: Bearer $API_KEY" \
    -H "Content-Type: application/json" \
    -d '{"public_key": "'"$CLIENT_PUBLIC_KEY"'"}')

if [ $? -ne 0 ]; then
    echo "$(date +%d/%m/%y\ %H:%M:%S) Erreur : Impossible de communiquer avec l'API."
    exit 1
fi

# Extraire la clé publique du serveur et l'endpoint depuis la réponse
SERVER_PUBLIC_KEY=$(echo "$RESPONSE" | jq --raw-output '.server_public_key')

# Vérifier si les valeurs sont valides
if [ -z "$SERVER_PUBLIC_KEY" ]; then
    echo "$(date +%d/%m/%y\ %H:%M:%S) Erreur : Réponse de l'API invalide."
    exit 1
fi

# Sauvegarder les informations reçues dans /data
echo "$SERVER_PUBLIC_KEY" > /data/server_public.key
echo "$REPONSE" > /data/data.json
echo "$(date +%d/%m/%y\ %H:%M:%S) Clé publique du serveur et endpoint enregistrés."

echo "$(date +%d/%m/%y\ %H:%M:%S) Installation terminée avec succès."
