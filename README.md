# Inception

Ce projet déploie une pile **LEMP** complète (Nginx, MySQL, PHP) dans un seul conteneur Docker. Il est conçu pour héberger **WordPress** et **phpMyAdmin** de manière sécurisée sous **HTTPS**.

## Options de Lancement

On a deux façons de lancer.

```
### Option A : Avec Docker CLI (Ligne de commande seule)

Utile pour un contrôle manuel total. Vous devez gérer la construction et les conflits de noms vous-même.

1. **Construire l'image :**
```powershell
docker build -t mon_image_inception .

```


2. **Nettoyer les anciens conteneurs (si nécessaire) :**
```powershell
docker rm -f inception_server

```


3. **Lancer le conteneur :**
```powershell
docker run -d `
  --name inception_server `
  -p 80:80 -p 443:443 `
  -v wordpress_data:/var/www/html `
  -v mysql_data:/var/lib/mysql `
  --env-file .env `
  mon_image_inception

```
4. **Surveiller des Logs**

```powershell
docker logs -f inception_server

```

---

### Option B : Avec Docker Compose
Pour gèrer automatiquement les volumes et le réseau.

1. **Construire et lancer :**
```powershell
docker-compose up --build
```

2. **Arrêter le projet :**
```powershell
docker-compose down
```

3. **Surveiller des Logs**

* **Si vous utilisez Docker Compose :**
```powershell
docker-compose logs -f
```

---

## Accès aux Services

Une fois le serveur lancé, ouvrez votre navigateur sur :

| Service | URL | Note |
| --- | --- | --- |
| **Accueil (Test)** | `https://localhost` | Vérifie la connexion à la base de données. |
| **WordPress** | `https://localhost/wp-admin` | Pour l'installation et la création d'articles. |
| **phpMyAdmin** | `https://localhost/phpmyadmin` | Pour gérer vos tables SQL. |

> **Certificat SSL :** Le certificat étant auto-signé, cliquez sur **"Avancé"** puis **"Continuer vers le site"** lors de la première connexion.

---

## Configuration (.env)

Assurez-vous d'avoir un fichier `.env` à la racine contenant vos identifiants :

## Maintenance & Debug

* **Nettoyage complet (supprime les volumes) :** `docker-compose down -v`
* **Entrer dans le conteneur :**
`docker exec -it inception_server bash`


