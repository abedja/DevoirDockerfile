FROM debian:buster

ENV DEBIAN_FRONTEND=noninteractive

# Configuration des dépôts Debian Buster (Archive)
RUN echo "deb http://archive.debian.org/debian/ buster main contrib non-free" > /etc/apt/sources.list \
    && echo "deb http://archive.debian.org/debian-security/ buster/updates main contrib non-free" >> /etc/apt/sources.list \
    && echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99no-check-valid-until

# Installation des outils de base
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    lsb-release \
    ca-certificates \
    apt-transport-https \
    && rm -rf /var/lib/apt/lists/*

# Ajout du dépôt MySQL
RUN wget https://dev.mysql.com/get/mysql-apt-config_0.8.13-1_all.deb \
    && DEBIAN_FRONTEND=noninteractive dpkg -i mysql-apt-config_0.8.13-1_all.deb \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys B7B3B788A8D3785C \
    && rm mysql-apt-config_0.8.13-1_all.deb

# Installation de la stack complète
RUN apt-get update && apt-get install -y \
    nginx \
    openssl \
    mysql-server \
    php7.3-fpm \
    php7.3-mysql \
    php7.3-mbstring \
    php7.3-xml \
    php7.3-curl \
    php7.3-gd \
    php7.3-zip \
    && rm -rf /var/lib/apt/lists/*

# Téléchargement de phpMyAdmin
RUN wget https://files.phpmyadmin.net/phpMyAdmin/5.0.2/phpMyAdmin-5.0.2-all-languages.tar.gz \
    && tar -xzf phpMyAdmin-5.0.2-all-languages.tar.gz \
    && mv phpMyAdmin-5.0.2-all-languages /var/www/html/phpmyadmin \
    && rm phpMyAdmin-5.0.2-all-languages.tar.gz

# Création des répertoires nécessaires
RUN mkdir -p /var/www/html \
    && mkdir -p /var/run/mysqld \
    && chown -R mysql:mysql /var/run/mysqld

# Copie des fichiers de configuration
COPY ./srcs/nginx.conf /etc/nginx/sites-available/default
COPY ./srcs/index.html /var/www/html/index.html
COPY ./srcs/index.php /var/www/html/index.php
COPY ./srcs/setup.sh /srcs/setup.sh

# Permissions
RUN chmod +x /srcs/setup.sh \
    && chown -R www-data:www-data /var/www/html

# Exposition des ports
EXPOSE 80 443

# Point d'entrée
WORKDIR /var/www/html
CMD ["bash", "/srcs/setup.sh"]