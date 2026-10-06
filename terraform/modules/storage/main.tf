resource "google_storage_bucket" "exports" {
  name                        = var.bucket_name
  location                    = var.location
  uniform_bucket_level_access = false
  public_access_prevention    = "inherited"
}
