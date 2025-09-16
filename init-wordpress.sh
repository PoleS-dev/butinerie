#!/bin/bash

# Script d'initialisation WordPress pour Docker
echo "🚀 Initialisation WordPress..."

# Attendre que la base de données soit prête
echo "⏳ Attente de la base de données..."
while ! mysql -h"db" -u"${DB_USER}" -p"${DB_PASS}" --skip-ssl -e "SELECT 1;" >/dev/null 2>&1; do
    sleep 2
done

# Vérifier si WordPress est installé (vérifier index.php)
if [ ! -f "/var/www/html/index.php" ]; then
    echo "📥 Téléchargement de WordPress..."
    # Télécharger WordPress si pas présent
    curl -s https://wordpress.org/latest.tar.gz | tar xz --strip-components=1 -C /var/www/html/
fi

# Copier wp-config.php depuis wp-source si absent
if [ ! -f "/var/www/html/wp-config.php" ] && [ -f "/wp-source/wp-config.php" ]; then
    echo "📝 Configuration de WordPress..."
    cp /wp-source/wp-config.php /var/www/html/wp-config.php
    chown www-data:www-data /var/www/html/wp-config.php
fi

# Vérifier si la base de données est vide et importer le backup
TABLE_COUNT=$(mysql -h"db" -u"${DB_USER}" -p"${DB_PASS}" --skip-ssl "${DB_NAME}" -e "SHOW TABLES;" 2>/dev/null | wc -l)
if [ "$TABLE_COUNT" -le 1 ]; then
    echo "📥 La base de données sera initialisée automatiquement par MariaDB avec backup-full.sql"
    echo "⏳ Attente de l'import automatique MariaDB..."

    # Attendre que MariaDB termine son import automatique
    sleep 10

    # Vérifier le résultat
    FINAL_COUNT=$(mysql -h"db" -u"${DB_USER}" -p"${DB_PASS}" --skip-ssl "${DB_NAME}" -e "SHOW TABLES;" 2>/dev/null | wc -l)

    if [ "$FINAL_COUNT" -gt 10 ]; then
        echo "✅ Import automatique réussi!"
        echo "📊 Total de $FINAL_COUNT tables importées (WordPress + tous les plugins)"
        echo "📋 Quelques tables importantes:"
        mysql -h"db" -u"${DB_USER}" -p"${DB_PASS}" --skip-ssl "${DB_NAME}" -e "SHOW TABLES;" 2>/dev/null | grep -E "(wp_options|wp_users|mailpoet|actionscheduler|cmplz)" | head -10
    else
        echo "⚠️  Import automatique échoué, tentative manuelle..."
        if [ -f "/sql/backup-full.sql" ]; then
            echo "📥 Import manuel de backup-full.sql..."
            mysql -h"db" -u"${DB_USER}" -p"${DB_PASS}" --skip-ssl "${DB_NAME}" < /sql/backup-full.sql
            echo "✅ Import manuel terminé!"
        fi
    fi
else
    echo "📊 Base de données déjà initialisée ($TABLE_COUNT tables présentes)"
    if [ "$TABLE_COUNT" -gt 10 ]; then
        echo "✅ Toutes les tables des plugins sont présentes!"
        echo "📋 Quelques tables importantes:"
        mysql -h"db" -u"${DB_USER}" -p"${DB_PASS}" --skip-ssl "${DB_NAME}" -e "SHOW TABLES;" 2>/dev/null | grep -E "(mailpoet|actionscheduler|cmplz)" | head -5
    else
        echo "⚠️  Seulement les tables WordPress de base présentes"
    fi
fi

echo "🔧 Mise à jour des URLs WordPress..."
# Mettre à jour les URLs pour l'environnement local
mysql -h"db" -u"${DB_USER}" -p"${DB_PASS}" --skip-ssl "${DB_NAME}" -e "UPDATE wp_options SET option_value='http://localhost:8084' WHERE option_name='home'; UPDATE wp_options SET option_value='http://localhost:8084' WHERE option_name='siteurl';" 2>/dev/null || true

echo "🎨 Synchronisation des thèmes..."
# Copier tous les thèmes depuis le volume monté
if [ -d "/wp-source/wp-content/themes" ]; then
    cp -r /wp-source/wp-content/themes/* /var/www/html/wp-content/themes/ 2>/dev/null || true
    chown -R www-data:www-data /var/www/html/wp-content/themes/
fi

echo "📦 Synchronisation des plugins..."
# Copier tous les plugins depuis le volume monté
if [ -d "/wp-source/wp-content/plugins" ]; then
    cp -r /wp-source/wp-content/plugins/* /var/www/html/wp-content/plugins/ 2>/dev/null || true
    chown -R www-data:www-data /var/www/html/wp-content/plugins/
fi

echo "📁 Synchronisation des uploads..."
# Copier les uploads depuis le volume monté
if [ -d "/wp-source/wp-content/uploads" ]; then
    cp -r /wp-source/wp-content/uploads/* /var/www/html/wp-content/uploads/ 2>/dev/null || true
    chown -R www-data:www-data /var/www/html/wp-content/uploads/
fi

echo "👤 Création de l'utilisateur administrateur..."
# Créer un utilisateur admin si pas déjà présent
ADMIN_USER=${ADMIN_USER:-"admin"}
ADMIN_EMAIL=${ADMIN_EMAIL:-"admin@localhost.local"}
ADMIN_PASS=${ADMIN_PASS:-"admin123"}

# Attendre que WP-CLI soit accessible
sleep 5

# Vérifier si l'utilisateur admin existe
if ! wp user get $ADMIN_USER --path=/var/www/html >/dev/null 2>&1; then
    echo "➕ Création de l'utilisateur admin..."
    wp user create $ADMIN_USER $ADMIN_EMAIL \
        --role=administrator \
        --user_pass=$ADMIN_PASS \
        --display_name="Administrateur Local" \
        --path=/var/www/html

    if [ $? -eq 0 ]; then
        echo "✅ Utilisateur admin créé:"
        echo "   👤 Username: $ADMIN_USER"
        echo "   📧 Email: $ADMIN_EMAIL"
        echo "   🔑 Password: $ADMIN_PASS"
        echo "   🌐 Login: http://localhost:8084/wp-admin"
    fi
else
    echo "ℹ️  Utilisateur admin '$ADMIN_USER' existe déjà"
fi

echo "✅ Initialisation terminée !"

# Démarrer Apache
exec "$@"