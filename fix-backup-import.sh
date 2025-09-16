#!/bin/bash

echo "🔧 Script de correction pour l'import du backup complet"

# Arrêter les conteneurs
echo "⏹️  Arrêt des conteneurs..."
docker-compose down

# Supprimer le volume de base de données
echo "🗑️  Suppression de l'ancienne base de données..."
docker volume rm butinerie_db_data 2>/dev/null || true

# Redémarrer les conteneurs
echo "🚀 Démarrage des nouveaux conteneurs..."
docker-compose up -d

# Attendre que MariaDB soit prêt
echo "⏳ Attente de MariaDB..."
sleep 30

# Copier et importer le backup complet
echo "📥 Import du backup complet..."
docker cp ./sql/backup-full.sql wp_db:/tmp/backup-full.sql

# Réinitialiser la base et importer
docker exec wp_db mysql -u root -proot_pass -e "DROP DATABASE IF EXISTS wp_db; CREATE DATABASE wp_db;"
docker exec wp_db sh -c "mysql -u root -proot_pass wp_db < /tmp/backup-full.sql"

# Vérifier le résultat
TABLES_COUNT=$(docker exec wp_db mysql -u root -proot_pass wp_db -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'wp_db';" | tail -1)

if [ "$TABLES_COUNT" -gt 100 ]; then
    echo "✅ Import réussi ! $TABLES_COUNT tables importées"
    echo "📋 Quelques tables des plugins :"
    docker exec wp_db mysql -u root -proot_pass wp_db -e "SHOW TABLES;" | grep -E "(mailpoet|actionscheduler|cmplz)" | head -10

    # Mettre à jour les URLs
    echo "🔧 Mise à jour des URLs WordPress..."
    docker exec wp_db mysql -u root -proot_pass wp_db -e "UPDATE wp_options SET option_value='http://localhost:8084' WHERE option_name IN ('home', 'siteurl');"

    echo "🎉 Configuration terminée ! Accédez à : http://localhost:8084"
else
    echo "❌ Échec de l'import. Seulement $TABLES_COUNT tables trouvées."
fi