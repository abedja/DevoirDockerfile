# Inception

**LEMP** complète (Nginx, MySQL, PHP) dans un seul conteneur Docker. Il est conçu pour héberger **WordPress** et **phpMyAdmin** de manière sous **HTTPS**.

## Lancement du Projet
### 1. Construire l'image
```powershell
docker build -t mon_image_inception .
```

### 2. Nettoyer les anciens conteneurs (si nécessaire)
```powershell
docker rm -f inception_server
```

### 3. Lancer le conteneur
```powershell
docker run -d `
  --name inception_server `
  -p 80:80 -p 443:443 `
  -v wordpress_data:/var/www/html `
  -v mysql_data:/var/lib/mysql `
  --env-file .env `
  mon_image_inception
```

### 4. Surveiller les Logs
```powershell
docker logs -f inception_server
```

---

## Accès aux Services

Une fois le serveur lancén:

| Service | URL | Note |
| --- | --- | --- |
| **Accueil (Test)** | `https://localhost` | Vérifie la connexion à la base de données. |
| **WordPress** | `https://localhost/wp-admin` | Pour l'installation et la création d'articles. |
| **phpMyAdmin** | `https://localhost/phpmyadmin` | Pour gérer vos tables SQL. |

> **Certificat SSL :** Le certificat étant auto-signé, cliquez sur **"Avancé"** puis **"Continuer vers le site"** lors de la première connexion.

---

## Configuration (.env)

On doit avoir un fichier `.env` à la racine contenant vos identifiants :
```env
MYSQL_ROOT_PASSWORD=votre_mot_de_passe_root
MYSQL_DATABASE=wordpress
MYSQL_USER=wp_user
MYSQL_PASSWORD=votre_mot_de_passe
```

---

## Maintenance & Debug

* **Arrêter le conteneur :** `docker stop inception_server`
* **Supprimer le conteneur :** `docker rm inception_server`
* **Nettoyage complet (supprime les volumes) :** `docker volume rm wordpress_data mysql_data`
* **Entrer dans le conteneur :** `docker exec -it inception_server bash`