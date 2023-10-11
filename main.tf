terraform {
  required_providers {
    terratowns = {
      source = "local.providers/local/terratowns"
      version = "1.0.0"
    }
  }
}

provider "terratowns" {
  endpoint = var.terratowns_endpoint
  user_uuid = var.teacherseat_user_uuid
  token = var.terratowns_access_token
}

module "terrahouse_aws" {
  source = "./modules/terrahouse_aws"
  user_uuid = var.teacherseat_user_uuid
  index_html_filepath = var.index_html_filepath
  error_html_filepath = var.error_html_filepath
  content_version = var.content_version
  assets_path = var.assets_path
}

resource "terratowns_home" "home" {
  name = "One Piece Manga from Eiichiro Oda"
  description = <<DESCRIPTION
"One Piece" is a highly popular and long-running Japanese manga series created by 
Eiichiro Oda. The story follows Monkey D. Luffy, a young and enthusiastic pirate with 
the ability to stretch his body like rubber after eating a Devil Fruit. Luffy aspires 
to become the Pirate King by finding the ultimate treasure, known as the One Piece, 
hidden at the end of the Grand Line. Along the way, he forms a diverse and loyal crew, 
the Straw Hat Pirates, and they embark on a grand adventure, encountering a wide array 
of characters, islands, and challenges. 
"One Piece" is celebrated for its intricate world-building, memorable characters, and 
a mix of action, humor, and heartwarming moments, making it one of the most beloved 
and successful manga series of all time.
DESCRIPTION
  domain_name = module.terrahouse_aws.cloudfront_url
  town = "missingo"
  content_version = 1
}