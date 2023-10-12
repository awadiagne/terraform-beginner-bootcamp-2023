terraform {
  required_providers {
    terratowns = {
      source = "local.providers/local/terratowns"
      version = "1.0.0"
    }
  }

  cloud {
    organization = "tf-beginner-bootcamp-2023"
    workspaces {
      name = "terra-house"
    }
  }
}

provider "terratowns" {
  endpoint = var.terratowns_endpoint
  user_uuid = var.teacherseat_user_uuid
  token = var.terratowns_access_token
}

module "home_one_piece_hosting" {
  source = "./modules/terrahome_aws"
  user_uuid = var.teacherseat_user_uuid
  content_version = var.one_piece.content_version
  public_path = var.one_piece.public_path
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
  domain_name = module.home_one_piece_hosting.domain_name
  town = "video-valley"
  content_version = 1
}

module "home_harry_potter_hosting" {
  source = "./modules/terrahome_aws"
  user_uuid = var.teacherseat_user_uuid
  public_path = var.harry_potter.public_path
  content_version = var.harry_potter.content_version
}

resource "terratowns_home" "home_harry_potter" {
  name = "Harry Potter from J.K Rowling"
  description = <<DESCRIPTION
"Harry Potter" is a popular fantasy book series written by J.K. Rowling. The story follows the adventures of 
a young wizard, Harry Potter, who learns of his magical abilities on his 11th birthday and embarks on a 
journey to the Hogwarts School of Witchcraft and Wizardry. Along with his friends Ron and Hermione, 
Harry uncovers his connection to the dark wizard Lord Voldemort and his quest for power. Over the course 
of seven books, the series explores themes of friendship, bravery, and the battle between good and evil 
in the magical world. The series has been immensely successful, both in literature and as a film franchise, 
captivating readers and viewers of all ages.
DESCRIPTION
  domain_name = module.home_harry_potter_hosting.domain_name
  town = "video-valley"
  content_version = var.harry_potter.content_version
}