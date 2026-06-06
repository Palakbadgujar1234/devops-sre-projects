variable "app_name" {
  description = "Name of the sample application"
  type        = string
  default     = "sample-sps-devsecops-app"
}

variable "environment" {
  description = "Target environment name"
  type        = string
  default     = "dev"
}

variable "owner" {
  description = "Owner of this sample infrastructure"
  type        = string
  default     = "beginner-devops-user"
}