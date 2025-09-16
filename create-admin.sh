#!/bin/bash

# Script pour créer un utilisateur administrateur WordPress
# Usage: ./create-admin.sh [username] [email] [password]

echo "👤 Création d'un utilisateur administrateur WordPress"

# Paramètres par défaut
DEFAULT_USERNAME="admin"
DEFAULT_EMAIL="admin@localhost.local"
DEFAULT_PASSWORD="admin123"

# Utiliser les paramètres fournis ou les valeurs par défaut
USERNAME=${1:-$DEFAULT_USERNAME}
EMAIL=${2:-$DEFAULT_EMAIL}
PASSWORD=${3:-$DEFAULT_PASSWORD}

echo "📋 Paramètres utilisateur:"
echo "   Username: $USERNAME"
echo "   Email: $EMAIL"
echo "   Password: $PASSWORD"

# Vérifier que WordPress est démarré
echo "⏳ Vérification que WordPress est accessible..."
sleep 5

# Vérifier si l'utilisateur existe déjà
EXISTING_USER=$(docker exec wp_cli wp user get $USERNAME --field=ID 2>/dev/null || echo "")

if [ -n "$EXISTING_USER" ]; then
    echo "⚠️  L'utilisateur '$USERNAME' existe déjà (ID: $EXISTING_USER)"
    echo "🔧 Mise à jour du mot de passe..."
    docker exec wp_cli wp user update $USERNAME --user_pass=$PASSWORD
    echo "✅ Mot de passe mis à jour pour '$USERNAME'"
else
    echo "➕ Création de l'utilisateur administrateur..."

    # Créer l'utilisateur administrateur
    USER_ID=$(docker exec wp_cli wp user create $USERNAME $EMAIL \
        --role=administrator \
        --user_pass=$PASSWORD \
        --display_name="Administrateur" \
        --first_name="Admin" \
        --last_name="Local" \
        --porcelain)

    if [ $? -eq 0 ]; then
        echo "✅ Utilisateur créé avec succès !"
        echo "   ID: $USER_ID"
        echo "   Username: $USERNAME"
        echo "   Email: $EMAIL"
        echo "   Password: $PASSWORD"
        echo "   Role: Administrator"
    else
        echo "❌ Erreur lors de la création de l'utilisateur"
        exit 1
    fi
fi

echo ""
echo "🌐 Connexion WordPress:"
echo "   URL: http://localhost:8084/wp-admin"
echo "   Username: $USERNAME"
echo "   Password: $PASSWORD"
echo ""
echo "✅ Configuration terminée !"