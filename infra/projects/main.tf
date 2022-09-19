# Create the Project
module "create_projects" {
  source   = "../modules/projects"
  projects = yamldecode(file("../../projects.yaml"))
  folder   = var.folder
  billing_account = var.billing_account
}
