#!/bin/bash
set -e

echo "=== INCEPTION SERVER SETUP ==="

# --- Préparation des répertoires ---
echo "[1/10] Préparation des répertoires..."
mkdir -p /var/run/mysqld
mkdir -p /run/php
chown -R mysql:mysql /var/run/mysqld /var/lib/mysql
chown -R www-data:www-data /run/php

# --- Initialisation de la base de données ---
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "[2/10] Initialisation de la structure MySQL..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
fi

# --- Démarrage sécurisé de MySQL ---
echo "[3/10] Démarrage de MySQL..."
mysqld_safe --datadir='/var/lib/mysql' &

# --- 4. Attente de la disponibilité de MySQL ---
echo "[4/10] Attente de MySQL..."
RETRIES=30
while ! mysqladmin ping -h localhost --silent; do
    echo "En attente de MySQL ($RETRIES restantes)..."
    sleep 2
    RETRIES=$((RETRIES - 1))
    if [ $RETRIES -eq 0 ]; then
        echo "ERREUR : MySQL n'a jamais démarré."
        exit 1
    fi
done
echo "MySQL est opérationnel."

# --- Configuration des utilisateurs et privilèges ---
# On crée un fichier SQL temporaire pour l'exécuter proprement
echo "[5/10] Configuration des accès MySQL..."
cat << EOF > /tmp/db_setup.sql
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'localhost' IDENTIFIED WITH mysql_native_password BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'localhost';
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF

# Tentative d'exécution : d'abord sans mot de passe, puis avec si échec
if mysql -u root < /tmp/db_setup.sql 2>/dev/null; then
    echo "Configuration appliquée avec succès (root sans pass)."
else
    echo "Tentative avec le mot de passe root existant..."
    mysql -u root -p${MYSQL_ROOT_PASSWORD} < /tmp/db_setup.sql
fi
rm /tmp/db_setup.sql

# --- Installation de WordPress ---
echo "[6/10] Vérification de WordPress..."
if [ ! -f "/var/www/html/wp-config.php" ]; then
    cd /var/www/html
    wget -q https://wordpress.org/latest.tar.gz
    tar -xzf latest.tar.gz --strip-components=1
    rm latest.tar.gz
    
    cp wp-config-sample.php wp-config.php
    sed -i "s/database_name_here/${MYSQL_DATABASE}/g" wp-config.php
    sed -i "s/username_here/${MYSQL_USER}/g" wp-config.php
    sed -i "s/password_here/${MYSQL_PASSWORD}/g" wp-config.php
    sed -i "s/localhost/localhost/g" wp-config.php
    echo "WordPress installé."
fi

# --- Configuration de PHP-FPM ---
echo "[7/10] Configuration de PHP-FPM (Unix Socket)..."
# On s'assure que PHP-FPM écoute bien sur le socket attendu par Nginx
sed -i 's|listen = /run/php/php7.3-fpm.sock|listen = /run/php/php7.3-fpm.sock|g' /etc/php/7.3/fpm/pool.d/www.conf

# --- Génération SSL ---
echo "[8/10] Vérification SSL..."
if [ ! -f "/etc/ssl/certs/nginx-selfsigned.crt" ]; then
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/ssl/private/nginx-selfsigned.key \
        -out /etc/ssl/certs/nginx-selfsigned.crt \
        -subj "/C=FR/ST=Paris/L=Paris/O=42/CN=localhost"
fi

# --- Permissions finales ---
echo "[9/10] Application des permissions..."
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# --- Lancement des services ---
echo "[10/10] Démarrage final des services..."
service php7.3-fpm start
service nginx start

echo "=========================================="
echo "SERVEUR INCEPTION PRÊT SUR HTTPS"
echo "=========================================="

# Maintenir le conteneur en vie
tail -f /dev/null