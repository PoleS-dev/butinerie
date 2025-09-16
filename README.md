# 🍯 Butinerie - Projet WordPress

**La Butinerie Pantin** - Maison du bien-vivre alimentaire
Application WordPress avec base de données MariaDB et PHPMyAdmin, containerisée avec Docker.

## 📋 Prérequis

- Docker & Docker Compose
- Git
- Port 8084 et 8086 disponibles

## 🚀 Démarrage rapide

### 1. Cloner le projet
```bash
git clone <URL_DU_REPO>
cd butinerie
```

### 2. Configuration de l'environnement
```bash
# Créer le fichier .env (si nécessaire)
cp .env.example .env

# Vérifier/modifier les paramètres dans .env
nano .env
```

**Variables d'environnement importantes dans .env :**
```env
# Base de données
DB_NAME=wp_db
DB_USER=wp_user
DB_PASS=wp_pass
DB_ROOT_PASS=root_pass

# Utilisateur admin automatique (optionnel)
ADMIN_USER=admin
ADMIN_EMAIL=admin@localhost.local
ADMIN_PASS=admin123
```

### 3. Démarrer l'application
```bash
# Démarrer tous les services
docker-compose up -d

# Suivre l'initialisation (important pour la première fois)
docker logs wp_app -f
```

### 4. Accéder au site
- **🌐 WordPress** : http://localhost:8084
- **🔐 Administration WordPress** : http://localhost:8084/wp-admin
  - Username : `admin` (ou votre ADMIN_USER)
  - Password : `admin123` (ou votre ADMIN_PASS)
- **🗄️ PhpMyAdmin** : http://localhost:8086 (root / root_pass)
- **⚡ WP-CLI** : `docker exec -it wp_cli wp --info`

## 📁 Structure du projet

```
butinerie/
├── docker-compose.yml     # Configuration Docker
├── Dockerfile            # Image WordPress personnalisée
├── init-wordpress.sh     # Script d'initialisation
├── create-admin.sh       # Script pour créer un admin manuellement
├── fix-backup-import.sh  # Script pour importer le backup complet
├── sync-uploads.sh       # Script pour synchroniser les images (2,4GB)
├── .env                  # Variables d'environnement
├── sql/
│   ├── backup-full.sql  # Backup COMPLET (415MB) - WordPress + WooCommerce + MailPoet + tous plugins
│   ├── backup.sql       # Backup minimal (281MB) - WordPress de base uniquement
│   └── backup-demo.sql  # Backup démo
└── wp/                  # Sources WordPress (thèmes, plugins)
    └── wp-content/
        ├── themes/       # Thèmes Enfold + défaut
        ├── plugins/
        └── uploads/
```

## ⚙️ Configuration

### Variables d'environnement (.env)

```env
# Base de données
DB_ROOT_PASS=root_pass
DB_NAME=wp_db
DB_USER=wp_user
DB_PASS=wp_pass

# WordPress URLs
WP_HOME=http://localhost:8084
WP_SITEURL=http://localhost:8084
```

### Ports utilisés

- **8084** : WordPress
- **8086** : PHPMyAdmin
- **3306** : MariaDB (interne)

## 🛠️ Commandes utiles

### Gestion Docker
```bash
# Démarrer tous les services
docker-compose up -d

# Suivre l'initialisation (première fois)
docker logs wp_app -f

# Voir l'état des conteneurs
docker-compose ps

# Arrêter les services
docker-compose down

# Redémarrer WordPress
docker-compose restart wordpress
```

### Base de données
```bash
# Accéder à MySQL
docker exec -it wp_db mysql -u root -proot_pass wp_db

# Vérifier les tables importées
docker exec wp_db mysql -u root -proot_pass wp_db -e "SHOW TABLES;"

# Sauvegarder la DB
docker exec wp_db mysqldump -u root -proot_pass wp_db > backup_$(date +%Y%m%d).sql

# Réinitialiser complètement la DB
docker-compose down
docker volume rm butinerie_db_data
docker-compose up -d
```

### WP-CLI
```bash
# Accéder à WP-CLI
docker exec -it wp_cli bash

# Lister les utilisateurs
docker exec wp_cli wp user list

# Lister les plugins
docker exec wp_cli wp plugin list

# Vider le cache
docker exec wp_cli wp cache flush
```

### Gestion des utilisateurs
```bash
# Créer un utilisateur admin manuellement
./create-admin.sh [username] [email] [password]

# Exemples :
./create-admin.sh                           # admin/admin@localhost.local/admin123
./create-admin.sh john john@example.com     # john/john@example.com/admin123
./create-admin.sh admin admin@site.com mypass123  # admin/admin@site.com/mypass123

# Lister les utilisateurs
docker exec wp_cli wp user list

# Changer un mot de passe
docker exec wp_cli wp user update admin --user_pass=nouveaumotdepasse
```

### Développement
```bash
# Voir les logs en temps réel
docker-compose logs -f

# Accéder au conteneur WordPress
docker exec -it wp_app bash

# Corriger les permissions
docker exec wp_app chown -R www-data:www-data /var/www/html
```

## 📊 Services

### WordPress (`wp_app`)
- **Image** : WordPress PHP 8.2 + Apache
- **Fonctionnalités automatiques** :
  - ✅ Téléchargement de WordPress si absent
  - ✅ Import automatique de **backup-full.sql** (COMPLET avec tous les plugins)
  - ✅ **Création automatique d'un utilisateur admin** (configurable via .env)
  - ✅ Synchronisation des thèmes/plugins depuis /wp
  - ✅ Configuration automatique des URLs locales
  - ✅ Correction des permissions

### MariaDB (`wp_db`)
- **Image** : MariaDB 10.11
- **Base de données** : `wp_db` créée automatiquement
- **Persistance** : Volume `butinerie_db_data`

### PHPMyAdmin (`wp_pma`)
- **Image** : PHPMyAdmin latest
- **Connexion** : Automatique à MariaDB
- **Accès** : root/root_pass

## 🎨 Thèmes et Plugins

Les thèmes et plugins sont **automatiquement synchronisés** depuis `wp/wp-content/` vers WordPress au démarrage.

**Thèmes disponibles :**
- Enfold (multiple versions)
- enfold-child
- Twenty Twenty (toutes versions)

**Pour ajouter du contenu :**
1. Placer les fichiers dans `wp/wp-content/themes/` ou `wp/wp-content/plugins/`
2. Redémarrer : `docker-compose restart wordpress`

## 🐛 Résolution de problèmes

### WordPress ne démarre pas
```bash
# Vérifier les logs d'initialisation
docker logs wp_app

# Tester la connexion base de données
docker exec wp_app mysql -h db -u wp_user -pwp_pass --skip-ssl -e "SELECT 1;"
```

### Base de données vide au démarrage
```bash
# Vérifier si backup-full.sql existe et sa taille
ls -lh sql/backup-full.sql

# Forcer la réimportation
docker-compose down
docker volume rm butinerie_db_data
docker-compose up -d
# Attendre 2-3 minutes pour l'import (415MB)
```

### Port déjà utilisé
```bash
# Modifier docker-compose.yml
ports:
  - "8085:80"  # WordPress
  - "8087:80"  # PHPMyAdmin
```

### Problème SSL MySQL
Le script corrige automatiquement les erreurs SSL avec `--skip-ssl`.

### WordPress inaccessible (403 Forbidden)
```bash
# Corriger les permissions
docker exec wp_app chown -R www-data:www-data /var/www/html/

# Vérifier que les fichiers WordPress sont présents
docker exec wp_app ls -la /var/www/html/index.php
```

## 📝 Notes importantes

- **⏱️ Première installation** : 2-3 minutes pour l'import de backup-full.sql (415MB avec TOUS les plugins)
- **🔄 Redémarrages** : BDD n'est pas réimportée si elle existe déjà
- **💾 Persistance** : Données WordPress et MariaDB persistées dans volumes
- **🌐 URLs** : Automatiquement configurées pour localhost:8084
- **🎨 Thèmes** : Enfold et thèmes par défaut disponibles
- **👤 Admin auto** : Utilisateur admin créé automatiquement (admin/admin123 par défaut)

## 🛠️ Scripts utiles

### Import complet de la base de données
```bash
# Si vous n'avez que les tables WordPress de base, utilisez ce script
./fix-backup-import.sh
```

### Création d'utilisateur admin
```bash
# Créer un nouvel admin ou modifier le mot de passe
./create-admin.sh [username] [email] [password]
```

### Synchronisation des images
```bash
# Copier toutes les images (2,4GB) vers WordPress
./sync-uploads.sh

# ⚠️ IMPORTANT: Exécutez ce script après le premier démarrage
# Les images ne sont pas automatiquement synchronisées au démarrage
```

## 🔍 Monitoring

```bash
# État des services
docker-compose ps

# Logs en temps réel
docker-compose logs -f

# Utilisation ressources
docker stats

# Vérifier l'import BDD
docker exec wp_db mysql -u root -proot_pass wp_db -e "SHOW TABLES;" | wc -l
```

## 🔒 Sécurité

⚠️ **IMPORTANT - SÉCURITÉ** ⚠️

### Code malveillant neutralisé
Le fichier `wp/wp-content/themes/enfold-child/functions.php` contenait du code malveillant qui :
- Créait des comptes administrateur cachés (`adminbackup`)
- Masquait ces utilisateurs de l'interface d'administration
- Empêchait leur suppression

**✅ Action prise :** Tout le code malveillant a été commenté et documenté. Le thème fonctionne maintenant de manière sécurisée.

### Configuration développement
Cette configuration est pour **développement local uniquement**.

Pour la production :
- Changer tous les mots de passe dans .env
- Nettoyer complètement le thème enfold-child
- Utiliser HTTPS
- Configurer un reverse proxy
- Activer les backups automatiques
- Restreindre l'accès PHPMyAdmin
- Scanner les thèmes/plugins pour d'autres vulnérabilités

## 📞 Support

**Problème courant :** WordPress en cours d'initialisation
```bash
# Suivre l'avancement
docker logs wp_app -f
# Attendre le message "✅ Initialisation terminée !"
```

**Debug complet :**
```bash
# 1. Vérifier l'état
docker-compose ps

# 2. Logs détaillés
docker logs wp_app --tail 20

# 3. Test connectivité BDD
docker exec wp_app mysql -h db -u wp_user -pwp_pass --skip-ssl wp_db -e "SELECT COUNT(*) FROM wp_options;"

# 4. Restart propre
docker-compose restart wordpress
```