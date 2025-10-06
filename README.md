# Miranui-n8n-sync
Ce projet permet de lancer un n8n sur clever Cloud et de versionner les templates n8n qui se trouvent dans le dossier local-files.

## 1. Gestions des environnements
### DEV

Pour lancer le projet en local utiliser `docker compose up -d` **définir les variables d'environnements suivant**:

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
### PREPROD

### PROD