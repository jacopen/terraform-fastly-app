terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "kusama"

    workspaces {
      name = "terraform-fastly-app"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "fastly" {

}

provider "aws" {
  region = "ap-northeast-1"
}


resource "aws_s3_bucket_policy" "jacopen_fastly_ui" {
  bucket = aws_s3_bucket.jacopen_fastly_ui.id

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "bucketpolicy"
    Statement = [
      {
        Sid       = "AddPerm"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource = [
          "${aws_s3_bucket.jacopen_fastly_ui.arn}/*"
        ]
      },
    ]
  })
}


resource "aws_s3_bucket" "jacopen_fastly_ui" {
  bucket = "jacopen-fastly-ui"
  acl    = "public-read"
  website {
    index_document = "index.html"
  }
}

resource "null_resource" "remove_and_upload_to_s3_ui" {
  provisioner "local-exec" {
    command = "aws s3 sync ${path.module}/ui s3://${aws_s3_bucket.jacopen_fastly_ui.id}"
  }
}
