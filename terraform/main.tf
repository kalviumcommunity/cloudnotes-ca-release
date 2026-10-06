module "storage" {
  source      = "./modules/storage"
  bucket_name = "cloudnotes-old-shared-exports"
  location    = var.storage_region
  expiry_days = 7
}
