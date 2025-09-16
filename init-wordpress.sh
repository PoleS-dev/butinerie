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
if [ ! -f "/var/www/html/wp-config.php" ]; then
    echo "📝 Configuration de WordPress..."
    if [ -f "/wp-source/wp-config.php" ]; then
        cp /wp-source/wp-config.php /var/www/html/wp-config.php
    else
        echo "⚠️  wp-config.php non trouvé dans wp-source, création d'un minimal..."
        # Créer un wp-config.php minimal si wp-source est vide
        cat > /var/www/html/wp-config.php << 'EOF'
<?php
define( 'DB_NAME',     getenv('DB_NAME') ?: 'wp_db' );
define( 'DB_USER',     getenv('DB_USER') ?: 'wp_user' );
define( 'DB_PASSWORD', getenv('DB_PASS') ?: 'wp_pass' );
define( 'DB_HOST',     'db:3306' );
define( 'WP_HOME',    getenv('WP_HOME') ?: 'http://localhost:8084' );
define( 'WP_SITEURL', getenv('WP_SITEURL') ?: 'http://localhost:8084' );
define( 'WP_DEBUG', false );
$table_prefix = 'wp_';
define('AUTH_KEY',         'your-key-here');
define('SECURE_AUTH_KEY',  'your-key-here');
define('LOGGED_IN_KEY',    'your-key-here');
define('NONCE_KEY',        'your-key-here');
define('AUTH_SALT',        'your-key-here');
define('SECURE_AUTH_SALT', 'your-key-here');
define('LOGGED_IN_SALT',   'your-key-here');
define('NONCE_SALT',       'your-key-here');
if ( ! defined( 'ABSPATH' ) ) define( 'ABSPATH', dirname(__FILE__) . '/' );
require_once( ABSPATH . 'wp-settings.php' );
EOF
    fi
    chown www-data:www-data /var/www/html/wp-config.php
fi

# Copier .htaccess depuis wp-source si absent
if [ ! -f "/var/www/html/.htaccess" ] && [ -f "/wp-source/.htaccess" ]; then
    echo "🔧 Configuration .htaccess..."
    cp /wp-source/.htaccess /var/www/html/.htaccess
    chown www-data:www-data /var/www/html/.htaccess
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

# Attendre que WordPress soit complètement chargé
sleep 10

# Créer l'admin directement via PHP
echo "➕ Création de l'utilisateur admin..."
php -r "
define('WP_USE_THEMES', false);
require_once('/var/www/html/wp-load.php');

\$admin_user = get_user_by('login', '$ADMIN_USER');
if (!\$admin_user) {
    \$user_data = array(
        'user_login' => '$ADMIN_USER',
        'user_pass' => '$ADMIN_PASS',
        'user_email' => '$ADMIN_EMAIL',
        'display_name' => 'Administrateur Local',
        'role' => 'administrator'
    );

    \$user_id = wp_insert_user(\$user_data);

    if (is_wp_error(\$user_id)) {
        echo 'Erreur création admin: ' . \$user_id->get_error_message();
    } else {
        echo '✅ Utilisateur admin créé avec succès!';
        echo '   👤 Username: $ADMIN_USER';
        echo '   📧 Email: $ADMIN_EMAIL';
        echo '   🔑 Password: $ADMIN_PASS';
        echo '   🌐 Login: http://localhost:8084/wp-admin';
    }
} else {
    echo 'ℹ️  Utilisateur admin existe déjà';
}
"

echo "✅ Initialisation terminée !"

# Démarrer Apache
exec "$@"