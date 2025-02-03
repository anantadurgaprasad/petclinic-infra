terraform {
  backend "s3" {
    bucket  = "terraform-state-bucket-durga"
    key     = "Statefile/terraform.tfstate"
    region  = "ap-south-1"
    profile = "personal-aws"
  }
}
