variable "bucket_name" {
  type        = string
  description = "Name of the exports bucket."
}

variable "location" {
  type        = string
  description = "Storage bucket location."
}

variable "expiry_days" {
  type        = number
  description = "Age in days at which exports are deleted."
}
