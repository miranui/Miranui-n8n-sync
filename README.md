# Miranui-n8n-sync

Petit projet pour déployer n8n sur Clever Cloud et versionner les templates de workflows n8n stockés dans le dossier `local-files`.

## But
- Fournir un environnement de développement local reproductible (Docker).
- Gérer et versionner les workflows n8n en JSON dans le dépôt.
- Faciliter le déploiement sur Clever Cloud.

## Fonctionnalités
- Lancement d'une instance n8n + PostgreSQL via Docker Compose.
- Variables d'environnement centralisées pour configurer n8n et la base.
- Dossier `local-files` : source de vérité pour les workflows exportés/importés.
- Procédure simple pour tester localement puis synchroniser les templates versionnés.

## Architecture (résumé)
- n8n (service principal)
- PostgreSQL (persistance)
- Dossier local `local-files` contenant les JSON des workflows

## Prérequis
- Docker & Docker Compose
- Compte Clever Cloud (pour déploiement)
- Git

## 1. Gestions des environnements
### DEV

Pour lancer le projet en local **définir les variables d'environnements suivant**:

- POSTGRES_USER=postgres
- POSTGRES_PASSWORD=postgres_password
- POSTGRES_DB=n8n_db

- N8N_BASIC_AUTH_USER=admin
- N8N_BASIC_AUTH_PASSWORD=admin_password

- OWNER_EMAIL=admin@example.com
- OWNER_PASSWORD=admin_password
- N8N_OWNER_FIRSTNAME=Admin
- N8N_OWNER_LASTNAME=User

- GENERIC_TIMEZONE=Europe/Paris
- N8N_DOMAIN_NAME=http://localhost:5678/
- N8N_ENCRYPTION_KEY=my_secret_key

- USER_TOKEN=workflow_user_token
- CLIENT_TOKEN=workflow_client_token
- CLIENT_KEY=workflow_client_key

Une fois les workflow testé il faut les importer au format json dans n8n et les mettre à jour dans le dossier local-files avant de le push

Pour tester que l'import des workflows fonctionne lancer les commandes suivantes et vérifier que les modifications ont bien été appliqué
```
docker compose down
docker compose build --no-cache
docker compose up -d
```
L'application sera accésible sur votre navigateur depuis http://localhost:5678/ (ou selon N8N_DOMAIN_NAME)

### PREPROD
Faite une pull request <branche-de-dev> -> main

Cela vas faire le déploiement dans l'instance de développement de miranui
La pipeline vas automatiquement déployer et / ou mettre à jour le n8n sur clever-cloud et vous pourrez y accéder depuis :

https://dev-miranui-n8n.cleverapps.io/

### PROD
# <font color="red">L'application en prod n'est pas encore disponible !!!

Une fois la décision de la création de la prod il ne faut pas oublier de créer les variables dans l'environnement de prod dans github

<a name="github-env-definition"></a>
Rendez-vous: https://github.com/miranui/Miranui-n8n-sync

Settings -> Code and automation - Environments -> prod
</font>


Un déploiement en prod sera lancé automatiquement lors du merge de la pull request une fois testé en dev

## Contribution
- Fork -> feature branch -> PR avec description claire des changements de workflow.
- Mettre à jour `local-files` pour tout changement de workflow.

## Licence et contact
- Licence : Miranui
- Contact : lucas.atabey@miranui.fr

Merci d'utiliser ce projet pour structurer et versionner vos automatisations n8n.
