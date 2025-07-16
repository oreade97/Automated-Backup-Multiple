variable "project_id" {
  description = "The Google Cloud project ID"
  type        = string
}

variable "region" {
  description = "The Google Cloud region for NetApp volume"
  type        = string
  default     = "us-central1"
}

variable "volume_path" {
  description = "The volume csv path"
  type        = string
  default     = "volumes.csv"
}

variable "volume_name" {
  description = "The NetApp volume name"
  type        = string
}

variable "backup_schedule" {
  description = "The cron schedule for the backup (Cloud Scheduler)"
  type        = string
  default     = "0 2 * * *"  # Default to daily at 2 AM
}

variable "service_account_key_file" {
  description = "The path to the service account key file"
}

variable "backup_vault_name" {
  description = "The name of the NetApp backup vault for storing backups"
  type        = string
  default     = "netapp-backup-vault"
}

variable "gcp_service_list" {
  type        = list(string)
  description = "The list of apis needed"
  default     = []
}
