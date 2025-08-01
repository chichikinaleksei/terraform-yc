resource "yandex_iam_service_account" "terraform_bot" {
  name      = "terraform-bot-new"
  folder_id = var.folder_id
}

# resource "yandex_iam_service_account_key" "terraform_bot_key" {
#   service_account_id = yandex_iam_service_account.terraform_bot.id
#   format             = "SA_KEY_JSON"

#   depends_on = [yandex_iam_service_account.terraform_bot]
# }

# resource "local_file" "service_account_key" {
#   content              = yandex_iam_service_account_key.terraform_bot_key.private_key
#   filename             = "${path.module}/generated-key.json"
#   file_permission      = "0600"
#   directory_permission = "0700"

#   depends_on = [yandex_iam_service_account_key.terraform_bot_key]
# }

# resource "yandex_resourcemanager_folder_iam_member" "editor_role" {
#   folder_id = var.folder_id
#   role      = "editor"
#   member    = "serviceAccount:${yandex_iam_service_account.terraform_bot.id}"

#   depends_on = [yandex_iam_service_account.terraform_bot]
# }

# resource "yandex_resourcemanager_folder_iam_member" "storage_admin_role" {
#   folder_id = var.folder_id
#   role      = "storage.admin"
#   member    = "serviceAccount:${yandex_iam_service_account.terraform_bot.id}"

#   depends_on = [yandex_iam_service_account.terraform_bot]
# }
