locals {
    name_prefix = "${var.project_name}-${var.environment}"
    demo_names = ["logs", "backups", "exports"]
}