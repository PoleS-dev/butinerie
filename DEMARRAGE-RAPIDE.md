# 🚀 Démarrage Rapide - WordPress La Butinerie

## Prérequis
- Docker installé et démarré
- docker-compose installé

## 🎯 Démarrage en une commande

```bash
./start.sh
```

C'est tout ! Le script s'occupe de tout automatiquement.

## 🌐 Accès au site

Une fois démarré, votre site sera accessible à :

- **Site web** : http://localhost:8084
- **Admin WordPress** : http://localhost:8084/wp-admin
- **PhpMyAdmin** : http://localhost:8086

## 🔑 Identifiants par défaut

- **Username** : `admin`
- **Password** : `admin123`
- **Email** : `admin@localhost.local`

## 🛠️ Commandes utiles

```bash
# Démarrer
./start.sh

# Arrêter
docker-compose down

# Redémarrer
docker-compose restart

# Voir les logs
docker-compose logs -f

# Accéder au shell WordPress
docker exec -it wp_app bash
```

## ❓ En cas de problème

### Page blanche ou erreur 404
Le script `start.sh` corrige automatiquement ce problème en copiant tous les fichiers nécessaires.

### Base de données vide
La base de données est automatiquement importée depuis `sql/backup-full.sql`.

### Permissions WordPress
Les permissions sont automatiquement corrigées par le script.

## 🔧 Pour les développeurs

Si vous voulez synchroniser les fichiers en temps réel pendant le développement, décommentez cette ligne dans `docker-compose.yml` :

```yaml
# - ./wp/wp-content:/var/www/html/wp-content
```

Puis redémarrez les conteneurs :
```bash
docker-compose down
docker-compose up -d
```

## 📁 Structure du projet

```
.
├── start.sh              # Script de démarrage automatique
├── docker-compose.yml    # Configuration Docker
├── wp/                   # Fichiers WordPress source
│   ├── wp-config.php
│   ├── .htaccess
│   └── wp-content/
└── sql/                  # Base de données
    └── backup-full.sql
```

## 🆘 Support

En cas de problème, vérifiez :
1. Que Docker est bien démarré
2. Que les ports 8084 et 8086 ne sont pas utilisés
3. Les logs avec `docker-compose logs`