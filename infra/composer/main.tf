# Create the Composer Envs
module "create_projects" {
  source          = "../modules/composer"
  projects        = yamldecode(file("../../config/projects.yaml"))
  location        = var.location
}
