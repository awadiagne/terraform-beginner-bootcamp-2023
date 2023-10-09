terraform {
  cloud {
    organization = "tf-beginner-bootcamp-2023"
    workspaces {
      name = "terraform-cloud"
    }
  }
}