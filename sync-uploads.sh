#!/bin/bash

echo "📁 Synchronisation des images WordPress..."

# Vérifier que le conteneur WordPress est en cours d'exécution
if ! docker ps | grep -q wp_app; then
    echo "❌ Le conteneur WordPress (wp_app) n'est pas en cours d'exécution"
    echo "💡 Démarrez-le avec: docker-compose up -d"
    exit 1
fi

# Vérifier la taille du dossier source
SOURCE_SIZE=$(du -sh ./wp/wp-content/uploads/ 2>/dev/null | cut -f1)
if [ -z "$SOURCE_SIZE" ]; then
    echo "❌ Dossier source ./wp/wp-content/uploads/ introuvable"
    exit 1
fi

echo "📊 Taille du dossier source: $SOURCE_SIZE"

# Copier tous les uploads
echo "📥 Copie des images vers le conteneur WordPress..."
docker cp ./wp/wp-content/uploads/. wp_app:/var/www/html/wp-content/uploads/

# Corriger les permissions
echo "🔧 Correction des permissions..."
docker exec wp_app chown -R www-data:www-data /var/www/html/wp-content/uploads/

# Vérifier le résultat
CONTAINER_SIZE=$(docker exec wp_app du -sh /var/www/html/wp-content/uploads/ | cut -f1)
echo "📊 Taille dans le conteneur: $CONTAINER_SIZE"

if [ "$SOURCE_SIZE" = "$CONTAINER_SIZE" ]; then
    echo "✅ Synchronisation réussie!"
    echo "🌐 Les images sont maintenant visibles sur: http://localhost:8084"
else
    echo "⚠️  Différence de taille détectée"
    echo "   Source: $SOURCE_SIZE"
    echo "   Conteneur: $CONTAINER_SIZE"
fi

echo ""
echo "💡 Si vous ajoutez de nouvelles images, relancez ce script:"
echo "   ./sync-uploads.sh"