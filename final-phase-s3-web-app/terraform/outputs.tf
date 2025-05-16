output "aws_s3_bucket" {
  description = "The Connecting The Dots S3 Web Application Bucket"
  value       = aws_s3_bucket.ctdc-s3-bucket.arn
}

output "aws_dynamodb" {
  description = "The Connecting The Dots DynamoDB Table"
  value       = aws_dynamodb_table.ctdc-dynamodb.id
}

output "api_invoke_url" {
  value = "https://${aws_api_gateway_rest_api.ctdc-api.id}.execute-api.${var.region}.amazonaws.com/${aws_api_gateway_stage.ctdc-api-stage.stage_name}"
}



