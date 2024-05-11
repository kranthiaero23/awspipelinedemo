
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region                  = var.region
  shared_credentials_file = "C:/Users/Kranthi.Vatti/.aws/credentials"
}

#Resource to create s3 bucket
resource "aws_s3_bucket" "demo-bucket"{
  bucket = var.bucketname

  tags = {
    Name = "S3Bucket"
  }
}

#Resource to enable versioning 
resource "aws_s3_bucket_versioning" "versioning_demo" {
  bucket = aws_s3_bucket.demo-bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

#Resource to enable encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "demo-encryption" {
  bucket = aws_s3_bucket.demo-bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

#######################

resource "aws_s3_bucket_public_access_block" "block_policy" {
bucket = aws_s3_bucket.demo-bucket.id
block_public_acls       = false
block_public_policy     = false
ignore_public_acls      = false
restrict_public_buckets = false
}

  resource "aws_s3_bucket_acl" "bucket_acl" {
    bucket = aws_s3_bucket.demo-bucket.id

    acl="public-read-write"
  }

  resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.demo-bucket.id
  policy = data.aws_iam_policy_document.allow_readwrite_access.json
}


data "aws_iam_policy_document" "allow_readwrite_access" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["248483680549"]
    }

    actions = [
      "s3:GetObject",
      "s3:ListBucket",
      "s3:PutObject"
    ]

    resources = [
      aws_s3_bucket.demo-bucket.arn,
      "${aws_s3_bucket.demo-bucket.arn}/*",
    ]
  }
} 

variable "region" {

}
variable "bucketname" {

}

