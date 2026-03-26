resource "aws_s3_bucket" "kubecost_federated_storage" {
  bucket        = var.kubecost_federated_storage_bucket_name
  force_destroy = true

  tags = merge(local.common_tags, {
    Name    = var.kubecost_federated_storage_bucket_name
    Purpose = "kubecost-federated-storage"
  })
}

resource "aws_s3_bucket_versioning" "kubecost_federated_storage" {
  bucket = aws_s3_bucket.kubecost_federated_storage.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "kubecost_federated_storage" {
  bucket = aws_s3_bucket.kubecost_federated_storage.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "kubecost_federated_storage" {
  bucket = aws_s3_bucket.kubecost_federated_storage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
