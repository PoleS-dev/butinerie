#!/bin/bash

echo "📦 Préparation du projet pour partage avec collègues"

# Créer un dossier de partage propre
SHARE_DIR="butinerie-share-$(date +%Y%m%d)"
echo "📁 Création du dossier de partage: $SHARE_DIR"

mkdir -p "$SHARE_DIR"

# Copier les fichiers essentiels (pas les gros fichiers)
echo "📋 Copie des fichiers de configuration..."
cp docker-compose.yml "$SHARE_DIR/"
cp Dockerfile "$SHARE_DIR/"
cp init-wordpress.sh "$SHARE_DIR/"
cp *.sh "$SHARE_DIR/"
cp *.md "$SHARE_DIR/"

# Copier le dossier wp sans uploads
echo "🎨 Copie des thèmes et plugins (sans images)..."
mkdir -p "$SHARE_DIR/wp/wp-content"
cp -r wp/wp-content/themes "$SHARE_DIR/wp/wp-content/" 2>/dev/null || true
cp -r wp/wp-content/plugins "$SHARE_DIR/wp/wp-content/" 2>/dev/null || true
cp wp/wp-config.php "$SHARE_DIR/wp/" 2>/dev/null || true

# Copier le SQL minimal
echo "🗄️ Copie du backup SQL minimal..."
mkdir -p "$SHARE_DIR/sql"
cp sql/backup.sql "$SHARE_DIR/sql/" 2>/dev/null || true
cp sql/backup-demo.sql "$SHARE_DIR/sql/" 2>/dev/null || true

# Créer un .env exemple
echo "⚙️ Création du fichier .env.example..."
cat > "$SHARE_DIR/.env.example" << EOF
# Base de données
DB_NAME=wp_db
DB_USER=wp_user
DB_PASS=wp_pass
DB_ROOT_PASS=root_pass

# Utilisateur admin automatique (optionnel)
ADMIN_USER=admin
ADMIN_EMAIL=admin@localhost.local
ADMIN_PASS=admin123
EOF

# Créer un .gitignore
echo "🚫 Création du .gitignore..."
cat > "$SHARE_DIR/.gitignore" << EOF
# Gros fichiers à exclure du git
sql/backup-full.sql
wp/wp-content/uploads/

# Fichiers environnement
.env

# Docker volumes
db_data/
wp_data/

# Logs
*.log

# OS
.DS_Store
Thumbs.db
EOF

# Instructions spéciales pour les gros fichiers
echo "📋 Création des instructions pour les gros fichiers..."
cat > "$SHARE_DIR/GROS-FICHIERS.md" << EOF
# 📁 Gros fichiers à ajouter séparément

Votre collègue doit vous fournir ces fichiers à placer manuellement :

## 1. Base de données complète
- **Fichier** : \`sql/backup-full.sql\` (415MB)
- **Où le mettre** : Dans le dossier \`sql/\`
- **Pourquoi** : Pour avoir toutes les tables (WooCommerce, MailPoet, etc.)

## 2. Images du site
- **Dossier** : \`wp/wp-content/uploads/\` (2,4GB)
- **Où le mettre** : Dans \`wp/wp-content/\`
- **Pourquoi** : Pour avoir toutes les images du site

## 📥 Comment les récupérer :
1. Demandez à votre collègue de partager ces fichiers via Google Drive/WeTransfer
2. Ou utilisez \`./fix-backup-import.sh\` et \`./sync-uploads.sh\` si vous avez accès à la source

## ⚡ Démarrage rapide après ajout :
\`\`\`bash
docker-compose up -d
./fix-backup-import.sh  # Si vous avez backup-full.sql
./sync-uploads.sh       # Si vous avez le dossier uploads
\`\`\`
EOF

# Calculer les tailles
SHARE_SIZE=$(du -sh "$SHARE_DIR" | cut -f1)
BACKUP_FULL_SIZE=$(du -sh sql/backup-full.sql 2>/dev/null | cut -f1 || echo "N/A")
UPLOADS_SIZE=$(du -sh wp/wp-content/uploads/ 2>/dev/null | cut -f1 || echo "N/A")

echo ""
echo "✅ Préparation terminée !"
echo "📊 Résumé des tailles :"
echo "   📦 Dossier partageable: $SHARE_SIZE"
echo "   🗄️ backup-full.sql: $BACKUP_FULL_SIZE (à partager séparément)"
echo "   🖼️ uploads/: $UPLOADS_SIZE (à partager séparément)"
echo ""
echo "📁 Dossier créé: $SHARE_DIR"
echo ""
echo "🚀 Options de partage :"
echo "   1. Compresser: tar -czf $SHARE_DIR.tar.gz $SHARE_DIR"
echo "   2. Git: cd $SHARE_DIR && git init && git add . && git commit -m 'Initial commit'"
echo "   3. Cloud: Uploader $SHARE_DIR sur Google Drive/OneDrive"
echo ""
echo "⚠️ N'oubliez pas de partager les gros fichiers séparément (voir GROS-FICHIERS.md)"