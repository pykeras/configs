#!/bin/sh
set -eu

DOMAIN="home.arpa"
CERTS_DIR="/etc/nginx/certs"
AUTH_DIR="/etc/nginx/auth"
PASSWORD="${REGISTRY_PASSWORD:-admin}"

mkdir -p "$CERTS_DIR" "$AUTH_DIR"
chmod 700 "$CERTS_DIR" || true

# 1) CA
if [ ! -f "$CERTS_DIR/rootCA.pem" ]; then
    echo "🔧 Generating Certificate Authority..."
    openssl genrsa -out "$CERTS_DIR/rootCA.key" 2048
    openssl req -x509 -new -nodes -key "$CERTS_DIR/rootCA.key" -sha256 -days 3650 \
        -out "$CERTS_DIR/rootCA.pem" -subj "/CN=InfraLocalRootCA"
    chmod 600 "$CERTS_DIR/rootCA.key"
fi

# 2) Server cert + SAN
if [ ! -f "$CERTS_DIR/server.crt" ] || [ ! -f "$CERTS_DIR/server.key" ]; then
    echo "🔧 Generating wildcard certificate for *.$DOMAIN..."
    cat >/tmp/san.cnf <<EOF
[req]
distinguished_name = req_distinguished_name
req_extensions = v3_req
prompt = no

[req_distinguished_name]
CN = *.$DOMAIN

[v3_req]
subjectAltName = @alt_names

[alt_names]
DNS.1 = *.$DOMAIN
DNS.2 = $DOMAIN
IP.1 = 192.168.1.21
IP.2 = 192.168.20.1
EOF

    openssl genrsa -out "$CERTS_DIR/server.key" 2048
    chmod 600 "$CERTS_DIR/server.key"
    openssl req -new -key "$CERTS_DIR/server.key" -out /tmp/server.csr -config /tmp/san.cnf
    openssl x509 -req -in /tmp/server.csr -CA "$CERTS_DIR/rootCA.pem" -CAkey "$CERTS_DIR/rootCA.key" \
        -CAcreateserial -out "$CERTS_DIR/server.crt" -days 825 -sha256 -extensions v3_req -extfile /tmp/san.cnf

    rm -f /tmp/server.csr /tmp/san.cnf
    echo "✅ SSL Certificate generated."
fi

# 3) htpasswd
if [ ! -f "$AUTH_DIR/.htpasswd" ]; then
    echo "🔧 Generating htpasswd file..."
    htpasswd -cbB "$AUTH_DIR/.htpasswd" admin "$PASSWORD"
    chmod 644 "$AUTH_DIR/.htpasswd"
fi

# 4) Helpful message
cat <<EOF
--------------------------------------------------
🚀 INFRASTRUCTURE READY
--------------------------------------------------
🔑 Install '$CERTS_DIR/rootCA.pem' on clients to trust services.
📡 Example services:
  - Registry: https://reg.home.arpa
  - GitLab:   https://git.home.arpa
  - Tutorials:https://tuts.home.arpa

🔒 Registry Login: docker login reg.home.arpa
   User: admin | Pass: $PASSWORD
--------------------------------------------------
EOF

exec nginx -g 'daemon off;'
