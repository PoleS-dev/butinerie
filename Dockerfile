FROM wordpress:php8.2-apache

# Installer les outils nécessaires
RUN apt-get update && apt-get install -y default-mysql-client curl && \
    curl -O https://raw.githubusercontent.com/wp-cli/wp-cli/v2.8.1/utils/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp && \
    rm -rf /var/lib/apt/lists/*

# Copier le script d'initialisation et le backup SQL
COPY init-wordpress.sh /usr/local/bin/init-wordpress.sh
COPY sql/backup.sql /backup.sql
RUN chmod +x /usr/local/bin/init-wordpress.sh

# Utiliser notre script d'initialisation
ENTRYPOINT ["/usr/local/bin/init-wordpress.sh"]
CMD ["apache2-foreground"]