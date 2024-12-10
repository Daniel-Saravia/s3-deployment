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

##############################
# Bucket Policy Configuration #
##############################

resource "aws_s3_bucket_policy" "hellofromterraform_policy" {
  bucket = aws_s3_bucket.hellofromterraform.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.hellofromterraform.arn}/*"
      }
    ]
  })
}

#############################
# Upload React Build Files  #
#############################

resource "aws_s3_object" "react_build" {
  for_each = fileset("/home/danielsaravia/Desktop/Shop/GCUEngineeringShop/client/build", "**/*")

  bucket = aws_s3_bucket.hellofromterraform.id
  key    = each.value
  source = "/home/danielsaravia/Desktop/Shop/GCUEngineeringShop/client/build/${each.value}"

  etag = filemd5("/home/danielsaravia/Desktop/Shop/GCUEngineeringShop/client/build/${each.value}")
}
