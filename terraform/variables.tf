variable "token" {
  description = "Clever cloud consumer key for authentication"
  type        = string
  sensitive   = true
}

variable "secret" {
  description = "Clever cloud consumer secret for authentication"
  type        = string
  sensitive   = true
}

variable "endpoint" {
  description = "Clever cloud API endpoint"
  type        = string
  sensitive   = true
}

variable "organisation" {
  description = "Clever cloud organisation name"
  type        = string
  sensitive   = true
}

variable "n8n_owner_email" {
  description = "n8n basic user"
  type        = string
}

variable "n8n_owner_password" {
  description = "n8n basic password"
  type        = string
}

variable "n8n_encryption_key" {
  description = "n8n encryption key for sensitive data"
  type        = string
  sensitive   = true
}

variable "user_token" {
  description = "Miranui API user token"
  type        = string
  sensitive   = true
}

variable "client_key" {
  description = "Miranui API client key"
  type        = string
  sensitive   = true
}

variable "client_token" {
  description = "Miranui API client token"
  type        = string
  sensitive   = true
}

variable "miranui_key" {
  description = "Miranui API client key"
  type        = string
  sensitive   = true
}

variable "miranui_token" {
  description = "Miranui API client token"
  type        = string
  sensitive   = true
}

variable "env_name" {
  description = "Environment name (dev, prod, ...)"
  type        = string
}
