output "name_prefix" {
  description = "prefixo de nome apos calculo"
  value = local.name_prefix
}

output "bucket_name" {
  description = "nome do nosso primeiro bucket"
  value = aws_s3_bucket.first.bucket
}

