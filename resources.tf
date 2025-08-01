resource "yandex_storage_bucket" "tf_state" {
  bucket     = "tf-state-student-new"
  # access_key = var.s3_access_key
  # secret_key = var.s3_secret_key
}
