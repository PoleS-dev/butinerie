#!/bin/bash

# Script pour corriger les URLs WordPress et éviter les redirections

echo "🔧 Correction des URLs WordPress..."

# Fonction pour mettre à jour les URLs
update_urls() {
    local NEW_URL="$1"

    echo "🌐 Mise à jour vers: $NEW_URL"

    # Mettre à jour les options principales
    docker exec wp_db mysql -u root -proot_pass wp_db -e "
        UPDATE wp_options SET option_value='$NEW_URL' WHERE option_name='home';
        UPDATE wp_options SET option_value='$NEW_URL' WHERE option_name='siteurl';
        UPDATE wp_options SET option_value='$NEW_URL' WHERE option_name='ping_sites';
    "

    # Mettre à jour les URLs dans le contenu (remplacer anciennes URLs)
    OLD_URLS=(
        "https://localhost:8084"
        "http://localhost:8084"
        "https://localhost"
        "http://localhost"
        "https://butinerie.local"
        "http://butinerie.local"
        "https://www.butinerie.com"
        "http://www.butinerie.com"
        "https://butinerie.com"
        "http://butinerie.com"
    )

    for old_url in "${OLD_URLS[@]}"; do
        echo "  🔄 Remplacement de $old_url par $NEW_URL"
        docker exec wp_db mysql -u root -proot_pass wp_db -e "
            UPDATE wp_posts SET post_content = REPLACE(post_content, '$old_url', '$NEW_URL');
            UPDATE wp_postmeta SET meta_value = REPLACE(meta_value, '$old_url', '$NEW_URL');
            UPDATE wp_options SET option_value = REPLACE(option_value, '$old_url', '$NEW_URL');
        "
    done

    # Désactiver les redirections automatiques
    docker exec wp_db mysql -u root -proot_pass wp_db -e "
        UPDATE wp_options SET option_value='0' WHERE option_name='blog_public';
        INSERT INTO wp_options (option_name, option_value, autoload)
        VALUES ('permalink_structure', '/%postname%/', 'yes')
        ON DUPLICATE KEY UPDATE option_value='/%postname%/';
    "

    echo "✅ URLs mises à jour vers $NEW_URL"
}

# Fonction pour obtenir l'IP du host Docker
get_docker_host_ip() {
    # Essayer différentes méthodes pour obtenir l'IP
    if command -v ip >/dev/null 2>&1; then
        ip route show default | awk '/default/ {print $3}' | head -1
    elif command -v route >/dev/null 2>&1; then
        route -n | awk '/^0.0.0.0/ {print $2}' | head -1
    else
        echo "host.docker.internal"
    fi
}

# Menu interactif
echo ""
echo "🎯 Choisissez l'URL cible:"
echo "1. http://localhost:8084 (par défaut)"
echo "2. IP Docker Host ($(get_docker_host_ip):8084)"
echo "3. URL personnalisée"
echo "4. Désactiver complètement les redirections"
echo ""

read -p "Votre choix (1-4): " choice

case $choice in
    1)
        update_urls "http://localhost:8084"
        ;;
    2)
        DOCKER_IP=$(get_docker_host_ip)
        update_urls "http://${DOCKER_IP}:8084"
        ;;
    3)
        read -p "Entrez l'URL complète (ex: http://192.168.1.100:8084): " custom_url
        update_urls "$custom_url"
        ;;
    4)
        echo "🚫 Désactivation des redirections..."
        docker exec wp_db mysql -u root -proot_pass wp_db -e "
            UPDATE wp_options SET option_value='' WHERE option_name='home';
            UPDATE wp_options SET option_value='' WHERE option_name='siteurl';
            DELETE FROM wp_options WHERE option_name='ping_sites';
        "
        echo "✅ Redirections désactivées"
        ;;
    *)
        echo "❌ Choix invalide"
        exit 1
        ;;
esac

# Redémarrer WordPress pour appliquer les changements
echo "🔄 Redémarrage de WordPress..."
docker-compose restart wordpress

echo ""
echo "✨ Terminé ! Testez votre site sur l'URL configurée."
echo "💡 Si vous avez encore des redirections, videz le cache de votre navigateur."