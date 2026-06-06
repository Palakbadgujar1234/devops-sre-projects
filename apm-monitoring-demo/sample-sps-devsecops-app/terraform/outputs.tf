output "generated_file_path" {
  description = "Path of the generated sample file"
  value       = local_file.app_info.filename
}

output "app_summary" {
  description = "Simple summary of the sample app"
  value       = "App ${var.app_name} is prepared for environment ${var.environment}"
}