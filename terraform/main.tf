terraform {
  required_providers {
    clevercloud = {
      source  = "CleverCloud/clevercloud"
      version = "1.0.1"
    }
  }
  backend "s3" {
    bucket                      = "lucas-backends-terraform"
    key                         = "miranuiN8nSync/state/env/terraform.tfstate" # this is a place holder
    region                      = "sbg"                                        # Random us region not used for ovh backend
    endpoints                   = { s3 = "https://s3.sbg.io.cloud.ovh.net" }
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    use_path_style              = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  }
}

provider "clevercloud" {
  token        = var.token
  secret       = var.secret
  endpoint     = var.endpoint
  organisation = var.organisation
}

resource "clevercloud_postgresql" "postgresql_database" {
  region = "par"
  name   = "${var.env_name}-miranui-n8n-sync-PSQL"
  plan   = "xxs_sml"
}

resource "clevercloud_docker" "docker_instance" {
  name   = "${var.env_name}-miranui-n8n-sync"
  region = "par"

  # horizontal scaling
  min_instance_count = 1
  max_instance_count = 1

  # vertical scaling
  smallest_flavor = "XS"
  biggest_flavor  = "XS"
  build_flavor    = "M"
  environment = {
    # n8n config
    # n8n + Postgres
    "DB_TYPE"                = "postgresdb"
    "DB_POSTGRESDB_HOST"     = clevercloud_postgresql.postgresql_database.host
    "DB_POSTGRESDB_PORT"     = tostring(clevercloud_postgresql.postgresql_database.port) # port est un nombre → string
    "DB_POSTGRESDB_DATABASE" = clevercloud_postgresql.postgresql_database.database
    "DB_POSTGRESDB_USER"     = clevercloud_postgresql.postgresql_database.user
    "DB_POSTGRESDB_PASSWORD" = clevercloud_postgresql.postgresql_database.password

    # auth n8n
    "N8N_USER_MANAGEMENT_DISABLED" = "false"
    "N8N_PROTOCOL"                 = "https"
    "WEBHOOK_URL" = format(
      "https://%s-miranui-n8n.cleverapps.io/",
      var.env_name == "dev" ? "dev" : ""
    )
    "OWNER_EMAIL"    = var.n8n_owner_email
    "OWNER_PASSWORD" = var.n8n_owner_password

    # autres
    "GENERIC_TIMEZONE"                      = "Europe/Paris"
    "CC_DOCKER_EXPOSED_HTTP_PORT"           = "5678" # port HTTP exposé côté Clever Cloud
    "N8N_ENCRYPTION_KEY"                    = var.n8n_encryption_key
    "N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS" = "true"
    "NODE_FUNCTION_ALLOW_ENV_ACCESS"        = "*"
    "NODE_FUNCTION_ALLOW_EXTERNAL"          = "*"
    "NODE_FUNCTION_ALLOW_BUILTIN"           = "*"
    "N8N_TRUST_PROXY"                       = "true"
    "N8N_RUNNERS_ENABLED"                   = "true"
    "N8N_BLOCK_ENV_ACCESS_IN_NODE"          = "false"
    "N8N_GIT_NODE_DISABLE_BARE_REPOS"       = "true"

    # n8n secrets
    "USER_TOKEN"   = var.user_token
    "CLIENT_TOKEN" = var.client_token
    "CLIENT_KEY"   = var.client_key

    # miranui api
    "N8N_KEY"   = var.miranui_key
    "N8N_TOKEN" = var.miranui_token
  }

  dependencies = [
    clevercloud_postgresql.postgresql_database.id
  ]
  depends_on = [clevercloud_postgresql.postgresql_database]
  deployment {
    repository = "https://github.com/Lucas-atabey/cleverPool-backend.git"
  }
}
