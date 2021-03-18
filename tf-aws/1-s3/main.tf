
resource "aws_s3_bucket" "tr_s3_bucket" {
  bucket = "tr-tf-test-bucket"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name        = "Tr bucket"
    Environment = "Dev"
  }
}

resource "aws_dynamodb_table" "basic-dynamodb-table-to-state-lock" {
  name = "tf-state-lock"
  #   billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "dynamodb-table-to-lock-state"
    Environment = "production"
  }
}
