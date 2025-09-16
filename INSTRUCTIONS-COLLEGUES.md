# 🍯 Butinerie - Instructions pour collègues

## 🚀 Démarrage rapide (5 minutes)

### 1. **Récupérer le projet**
```bash
# Option A: Git
git clone https://github.com/VOTRE-USERNAME/butinerie.git
cd butinerie

# Option B: Archive
# Télécharger + extraire l'archive
cd butinerie-projet
```

### 2. **Configuration**
```bash
# Copier la configuration (si nécessaire)
cp .env.example .env
```

### 3. **Démarrage**
```bash
# Démarrer Docker
docker-compose up -d

# Attendre 1-2 minutes puis corriger la base de données
./fix-backup-import.sh

# Synchroniser les images (si disponibles)
./sync-uploads.sh
```

### 4. **Accès**
- **Site** : http://localhost:8084
- **Admin** : http://localhost:8084/wp-admin
- **Comptes** : limbus, butinerie, solen, coordination
- **PhpMyAdmin** : http://localhost:8086

---

## ⚠️ **Problèmes courants**

### "J'ai seulement 10 tables au lieu de 143"
```bash
./fix-backup-import.sh
```

### "Les images ne s'affichent pas"
```bash
./sync-uploads.sh
```

### "Port 8084 déjà utilisé"
```bash
# Modifier docker-compose.yml:
ports:
  - "8085:80"  # Au lieu de 8084
```

### "Erreur de permissions"
```bash
sudo chown -R $USER:$USER .
```

---

## 📞 **Besoin d'aide ?**

1. **Logs** : `docker logs wp_app -f`
2. **Redémarrage propre** :
   ```bash
   docker-compose down
   docker volume rm butinerie_db_data butinerie_wp_data
   docker-compose up -d
   ./fix-backup-import.sh
   ./sync-uploads.sh
   ```
3. **Contact** : [VOTRE-EMAIL]

---

## 🎯 **Ce que vous obtenez**

- ✅ WordPress complet avec Enfold
- ✅ WooCommerce configuré
- ✅ MailPoet pour newsletters
- ✅ 143 tables de plugins
- ✅ 2,4GB d'images (si synchronisées)
- ✅ Thème sécurisé (code malveillant neutralisé)

**Temps total de setup : 5 minutes maximum** ⚡