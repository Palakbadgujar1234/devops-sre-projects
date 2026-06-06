terraform {
  required_version = ">= 1.5.0"
}

resource "local_file" "app_info" {
  filename = "${path.module}/generated-app-info.txt"
  content  = <<EOT
app_name=${var.app_name}
environment=${var.environment}
owner=${var.owner}
EOT
}