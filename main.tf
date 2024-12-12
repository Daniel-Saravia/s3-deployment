provider "aws" {
  region = "us-east-1"
}

########################
# S3 Bucket Definition #
########################
resource "aws_s3_bucket" "hellofromterraform" {
  bucket = "hellofromterraform"

  # Tags for identification
  tags = {
    Name        = "Hello From Terraform Bucket"
    Environment = "Development"
  }
}

####################################
# Turn Off "Block All Public Access"
####################################
resource "aws_s3_bucket_public_access_block" "public_access_settings" {
  bucket = aws_s3_bucket.hellofromterraform.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

#########################
# Bucket Policy for Read #
#########################
resource "aws_s3_bucket_policy" "allow_public_read" {
  bucket = aws_s3_bucket.hellofromterraform.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowPublicRead"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.hellofromterraform.arn}/*"
      }
    ]
  })
}

#################################
# Enable Static Website Hosting #
#################################
resource "aws_s3_bucket_website_configuration" "website_config" {
  bucket = aws_s3_bucket.hellofromterraform.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

#############################
# Upload React Build Files  #
#############################
resource "aws_s3_object" "react_build" {
  for_each = fileset("/home/danielsaravia/Desktop/Shop/GCUEngineeringShop/client/build", "**/*")

  bucket = aws_s3_bucket.hellofromterraform.id
  key    = each.value
  source = "/home/danielsaravia/Desktop/Shop/GCUEngineeringShop/client/build/${each.value}"
  etag   = filemd5("/home/danielsaravia/Desktop/Shop/GCUEngineeringShop/client/build/${each.value}")

  # Correct content type
  content_type = lookup(
    {
      "html" = "text/html"
      "css"  = "text/css"
      "js"   = "application/javascript"
      "json" = "application/json"
      "png"  = "image/png"
      "ico"  = "image/x-icon"
      "webp" = "image/webp"
      "txt"  = "text/plain"
    },
    split(".", each.value)[length(split(".", each.value)) - 1],
    "application/octet-stream" # Default Content-Type
  )
}


