terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = "ap-northeast-2"
  profile = "hong"
}

# 전체 상태 파일 bucket
resource "aws_s3_bucket" "navie_allstate" {
  bucket = "navie-bucket-state-navie-web-project"
  tags = {
    Name = "navie-allstate"
  }
  lifecycle {
    #prevent_destroy = true
  }
  force_destroy = true
}
# allstate versioning 
resource "aws_s3_bucket_versioning" "navie_state_ver" {
  bucket = aws_s3_bucket.navie_allstate.id
  versioning_configuration {
    status = "Enabled"
  }
}

# video public access
resource "aws_s3_bucket_public_access_block" "video_access_block" {
  bucket = "navie-bucket-video-save-web"

  block_public_acls       = true
  block_public_policy     = false # 정책 생성하고나서 true로 다시 변경
  ignore_public_acls      = false
  restrict_public_buckets = false # 정책 생성하고나서 true로 다시 변경
}
# video bucket 
resource "aws_s3_bucket" "navie_video" {
  bucket = "navie-bucket-video-save-web"
  tags = {
    Name = "navie-video"
  }
  lifecycle {
    #prevent_destroy = true
  }
  force_destroy = true
}

# video policy
resource "aws_s3_bucket_policy" "video_allow" {
  bucket = "navie-bucket-video-save-web"

  policy = <<POLICY
{
  "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::navie-bucket-video-save-web/*",
            "Condition": {
                "StringLike": {
                    "aws:Referer": [
                        "http://www.navie.world/*",
                        "https://www.navie.world/*"
                    ]
                }
            }
        }
    ]
}
POLICY
depends_on = [ aws_s3_bucket_public_access_block.video_access_block ]
}

# video cors
resource "aws_s3_bucket_cors_configuration" "video_cors" {
  bucket = "navie-bucket-video-save-web"
  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET"]
    allowed_origins = ["https://navie.world", "http://www.navie.world" ]
    expose_headers  = []
  }
  depends_on = [ aws_s3_bucket_public_access_block.video_access_block ]
}



# video versioning 
resource "aws_s3_bucket_versioning" "navie_video_ver" {
  bucket = aws_s3_bucket.navie_video.id
  versioning_configuration {
    status = "Enabled"
  }
}


# images public access
resource "aws_s3_bucket_public_access_block" "images_access_block" {
  bucket = "navie-bucket-images-save-web"

  block_public_acls       = true
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false 
}
# image bucket 
resource "aws_s3_bucket" "navie_images" {
  bucket = "navie-bucket-images-save-web"
  tags = {
    Name = "navie-images"
  }
  lifecycle {
    #prevent_destroy = true
  }
  force_destroy = true
}

#ownership
resource "aws_s3_bucket_ownership_controls" "image_ownership" {
  bucket = aws_s3_bucket.navie_images.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}


#image policy
resource "aws_s3_bucket_policy" "image_allow" {
  bucket = "navie-bucket-images-save-web"

  policy = <<POLICY
{
  "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::navie-bucket-images-save-web/*",
            "Condition": {
                "StringLike": {
                    "aws:Referer": [
                        "http://www.navie.world/*",
                        "https://www.navie.world/*"
                    ]
                }
            }
        }
    ]
}
POLICY
depends_on = [ aws_s3_bucket_public_access_block.images_access_block ]
}

# images cors
resource "aws_s3_bucket_cors_configuration" "images_cors" {
  bucket = "navie-bucket-images-save-web"
  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET"]
    allowed_origins = ["https://navie.world", "http://www.navie.world" ]
    expose_headers  = []
  }
  depends_on = [ aws_s3_bucket_public_access_block.images_access_block ]
}

#acl 설정
resource "aws_s3_bucket_acl" "image_acl" {
  depends_on = [
    aws_s3_bucket_ownership_controls.image_ownership,
    aws_s3_bucket_public_access_block.images_access_block,
  ]

  bucket = aws_s3_bucket.navie_images.id
  acl    = "public-read"
}



# "uri=http://acs:aws:iam::191635887465:user/hong"
# images versioning 
resource "aws_s3_bucket_versioning" "navie_images_ver" {
  bucket = aws_s3_bucket.navie_images.id
  versioning_configuration {
    status = "Enabled"
  }
}


# baordfile bucket
resource "aws_s3_bucket" "navie_boardfile" {
  bucket = "navie-bucket-board-save-web"
  tags = {
    Name = "navie-boardfile"
  }
  lifecycle {
    #prevent_destroy = true
  }
  force_destroy = true
}
# boardfile versioning 
resource "aws_s3_bucket_versioning" "navie_boardfile_ver" {
  bucket = aws_s3_bucket.navie_boardfile.id
  versioning_configuration {
    status = "Enabled"
  }
}
#############################################################################################################################
#############################################################################################################################
#############################################################################################################################

resource "aws_kms_key" "navie_allstate_kms" {
  description             = "navie_allstate_kms"
  deletion_window_in_days = 7
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_sec" {
  bucket = aws_s3_bucket.navie_allstate.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.navie_allstate_kms.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

#############################################################################################################################
#############################################################################################################################
#############################################################################################################################


# # 여러 사람이 사용할 때 충돌을 방지하고 일관성을 유지하기 위해 잠금 설정
# resource "aws_dynamodb_table" "terraform_locks" {
#   name         = "navieTerraform-bucket-lock"
#   billing_mode = "PAY_PER_REQUEST"
#   hash_key     = "LockID"

#   attribute {
#     name = "LockID"
#     type = "S"
#   }
# }