#!/bin/bash

# Script pour créer une sauvegarde minimale de WordPress
# Exporte seulement les données essentielles

echo "🗂️  Création d'une sauvegarde minimale WordPress..."

# Tables essentielles à exporter
ESSENTIAL_TABLES=(
    "wp_options"          # Configuration WordPress
    "wp_users"            # Utilisateurs
    "wp_usermeta"         # Métadonnées utilisateurs
    "wp_terms"            # Taxonomies
    "wp_term_taxonomy"    # Relations taxonomies
    "wp_term_relationships" # Relations posts-taxonomies
    "wp_posts"            # Articles et pages
    "wp_postmeta"         # Métadonnées posts
    "wp_comments"         # Commentaires (optionnel)
    "wp_commentmeta"      # Métadonnées commentaires (optionnel)
)

# Fichier de sortie
OUTPUT_FILE="sql/backup-minimal.sql"
TEMP_FILE="sql/backup-temp.sql"

# Créer l'en-tête du fichier SQL
cat > "$OUTPUT_FILE" << 'EOF'
-- WordPress Minimal Backup
-- Généré automatiquement avec create-minimal-backup.sh
-- Contient uniquement les données essentielles

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

EOF

echo "📥 Export des tables essentielles..."

# Exporter chaque table essentielle
for table in "${ESSENTIAL_TABLES[@]}"; do
    echo "  - Export de $table"

    # Vérifier si la table existe
    TABLE_EXISTS=$(docker exec wp_db mysql -u root -proot_pass wp_db -e "SHOW TABLES LIKE '$table';" | wc -l)

    if [ "$TABLE_EXISTS" -gt 1 ]; then
        # Exporter la structure et les données
        docker exec wp_db mysqldump -u root -proot_pass wp_db "$table" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
    else
        echo "    ⚠️  Table $table non trouvée, ignorée"
    fi
done

# Ajouter le pied de page SQL
cat >> "$OUTPUT_FILE" << 'EOF'

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

COMMIT;
EOF

# Afficher les statistiques
ORIGINAL_SIZE=$(ls -lh sql/backup.sql 2>/dev/null | awk '{print $5}' || echo "N/A")
NEW_SIZE=$(ls -lh "$OUTPUT_FILE" | awk '{print $5}')

echo ""
echo "✅ Sauvegarde minimale créée !"
echo "📁 Fichier: $OUTPUT_FILE"
echo "📊 Taille originale: $ORIGINAL_SIZE"
echo "📊 Taille minimale: $NEW_SIZE"
echo ""
echo "🔄 Pour utiliser cette sauvegarde :"
echo "   1. mv sql/backup.sql sql/backup-full.sql"
echo "   2. mv sql/backup-minimal.sql sql/backup.sql"
echo "   3. docker-compose down && docker volume rm butinerie_db_data"
echo "   4. docker-compose up -d"