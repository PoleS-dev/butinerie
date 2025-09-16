#!/bin/bash

# Script de démarrage simple pour les collègues
# Ce script lance WordPress et copie automatiquement les fichiers nécessaires

set -e

echo "🚀 Démarrage de l'environnement WordPress La Butinerie..."

# Vérifier que Docker est installé et en cours d'exécution
if ! command -v docker &> /dev/null; then
    echo "❌ Docker n'est pas installé. Veuillez l'installer d'abord."
    exit 1
fi

if ! docker info &> /dev/null; then
    echo "❌ Docker n'est pas démarré. Veuillez démarrer Docker d'abord."
    exit 1
fi

# Vérifier que docker-compose est disponible
if ! command -v docker-compose &> /dev/null; then
    echo "❌ docker-compose n'est pas installé. Veuillez l'installer d'abord."
    exit 1
fi

# Arrêter les conteneurs existants s'ils tournent
echo "🛑 Arrêt des conteneurs existants..."
docker-compose down 2>/dev/null || true

# Démarrer les conteneurs
echo "🐳 Démarrage des conteneurs Docker..."
docker-compose up -d

echo "⏳ Attente du démarrage des services..."
sleep 15

# Vérifier que les conteneurs sont en cours d'exécution
if ! docker-compose ps | grep -q "Up"; then
    echo "❌ Erreur lors du démarrage des conteneurs"
    docker-compose logs
    exit 1
fi

# Copier les fichiers WordPress essentiels s'ils ne sont pas dans le conteneur
echo "📁 Synchronisation des fichiers WordPress..."

# Vérifier et copier wp-config.php
if [ -f "wp/wp-config.php" ]; then
    echo "   📝 Copie de wp-config.php..."
    docker cp wp/wp-config.php wp_app:/var/www/html/wp-config.php
fi

# Vérifier et copier .htaccess
if [ -f "wp/.htaccess" ]; then
    echo "   🔧 Copie de .htaccess..."
    docker cp wp/.htaccess wp_app:/var/www/html/.htaccess
fi

# Vérifier et copier wp-content
if [ -d "wp/wp-content" ]; then
    echo "   🎨 Copie de wp-content (thèmes, plugins, uploads)..."
    docker cp wp/wp-content wp_app:/var/www/html/
fi

# Fixer les permissions
echo "🔐 Correction des permissions..."
docker exec wp_app chown -R www-data:www-data /var/www/html

# Créer l'utilisateur admin si nécessaire
echo "👤 Vérification de l'utilisateur admin..."
docker exec wp_app php -r "
define('WP_USE_THEMES', false);
require_once('/var/www/html/wp-load.php');

\$admin_user = get_user_by('login', 'admin');
if (!\$admin_user) {
    \$user_data = array(
        'user_login' => 'admin',
        'user_pass' => 'admin123',
        'user_email' => 'admin@localhost.local',
        'display_name' => 'Administrateur Local',
        'role' => 'administrator'
    );
    \$user_id = wp_insert_user(\$user_data);
    if (!is_wp_error(\$user_id)) {
        echo 'Admin créé: admin/admin123';
    }
} else {
    echo 'Admin existe déjà';
}
" 2>/dev/null || echo "Admin sera créé au premier démarrage WordPress"

# Tester la connexion
echo "🧪 Test de la connexion..."
sleep 5

if curl -s http://localhost:8084 | grep -q "butinerie\|wordpress\|html"; then
    echo "✅ WordPress est démarré avec succès !"
    echo ""
    echo "🌐 Votre site WordPress est accessible à :"
    echo "   👉 Site web: http://localhost:8084"
    echo "   🔑 Admin: http://localhost:8084/wp-admin"
    echo "   🗄️  PhpMyAdmin: http://localhost:8086"
    echo ""
    echo "📋 Informations de connexion :"
    echo "   👤 Username: admin"
    echo "   🔑 Password: admin123"
    echo "   📧 Email: admin@localhost.local"
    echo ""
    echo "📊 Statut des conteneurs :"
    docker-compose ps
else
    echo "⚠️  WordPress démarre encore, patientez quelques instants..."
    echo "🔍 Vérifiez http://localhost:8084 dans votre navigateur"
fi

echo ""
echo "🛠️  Commandes utiles :"
echo "   • Arrêter: docker-compose down"
echo "   • Redémarrer: docker-compose restart"
echo "   • Logs: docker-compose logs -f"
echo "   • Shell WordPress: docker exec -it wp_app bash"
