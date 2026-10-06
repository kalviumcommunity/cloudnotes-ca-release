variable "bucket_name" {
  type        = string
  description = "Name of the exports bucket."
  default     = "cloudnotes-ca-example-exports"
}

variable "region" {
  type        = string
  description = "Location of the exports bucket."
  default     = "asia-south1"
}

variable "expiry_days" {
  type        = number
  description = "Age in days at which exports are deleted."
  default     = 30
}
