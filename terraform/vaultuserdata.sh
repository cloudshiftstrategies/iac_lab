# Update all packages
yum update -y

#yum install -y letsencrypt openssl libjson-pp-perl

# Install Vault
wget https://releases.hashicorp.com/vault/0.9.1/vault_0.9.1_linux_amd64.zip
unzip -j vault_*_linux_amd64.zip -d /usr/local/bin

# Add a user for the vault daemon
useradd -r -g daemon -d /usr/local/vault -m -s /sbin/nologin -c "Vault user" vault

# Create a config directory remove global access
mkdir /etc/vault /etc/ssl/vault
chown vault.root /etc/vault /etc/ssl/vault
chmod 750 /etc/vault /etc/ssl/vault
chmod 700 /usr/local/vault

# get an SSL SAN Certificate
#letsencrypt --webroot -w /home/www/vhosts/default/public -d myfirstdomain.com -d myseconddomain.com

# Copy the certficates and key
#cp -v /etc/letsencrypt/live/myfirstdomain.com/*pem /etc/ssl/vault
#/etc/letsencrypt/live/myfirstdomain.com/cert.pem -> /etc/ssl/vault/cert.pem
#/etc/letsencrypt/live/myfirstdomain.com/chain.pem -> /etc/ssl/vault/chain.pem
#/etc/letsencrypt/live/myfirstdomain.com/fullchain.pem -> /etc/ssl/vault/fullchain.pem
#/etc/letsencrypt/live/myfirstdomain.com/privkey.pem -> /etc/ssl/vault/privkey.pem

# Create a combined PEM certificate
#$ sudo cat /etc/ssl/vault/{cert,fullchain}.pem /etc/ssl/vault/fullcert.pem

# Write the config to file
cat <<EOF | sudo tee /etc/vault/config.hcl
listener "tcp" {
	address = "0.0.0.0:8200"
	tls_disable = 1
	#tls_disable = 0
	#tls_cert_file = "/etc/ssl/vault/fullcert.pem"
	#tls_key_file = "/etc/ssl/vault/privkey.pem"
}
backend "file" {
	path = "/usr/local/vault/data"
}
disable_mlock = true
EOF

# Create the startup script
cat <<EOF | sudo tee /usr/lib/systemd/system/vault.service
[Unit]
Description=Vault service
After=network-online.target

[Service]
User=vault
Group=daemon
PrivateDevices=yes
PrivateTmp=yes
ProtectSystem=full
ProtectHome=read-only
SecureBits=keep-caps
Capabilities=CAP_IPC_LOCK+ep
CapabilityBoundingSet=CAP_SYSLOG CAP_IPC_LOCK
NoNewPrivileges=yes
ExecStart=/usr/local/bin/vault server -config=/etc/vault/config.hcl
KillSignal=SIGINT
TimeoutStopSec=30s
Restart=on-failure
StartLimitInterval=60s
StartLimitBurst=3

[Install]
WantedBy=multi-user.target
EOF

# Start the vault daemon
systemctl daemon-reload
systemctl start vault
systemctl enable vault

# Start the vault server
#sudo -su vault vault server -config=/etc/vault/config.hcl >/tmp/vault-debug.log 2>&1 &
export VAULT_ADDR=https://127.0.0.1:8200
/usr/local/bin/vault status
