FROM alpine:3.18

# Installer WireGuard et dépendances
RUN apk add --no-cache wireguard-tools bash jq

# Copier le script de démarrage
COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD [ "/run.sh" ]
