provider "aws" {
  region = var.region
}

terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

resource "random_id" "ctd-random-number" {
  byte_length = 8
}

resource "aws_s3_bucket" "ctd-s3-bucket" {
  bucket = "ctd-frontend-${random_id.ctd-random-number.hex}"
  tags = {
    Name = var.project_tag
  }
}

resource "aws_s3_bucket_public_access_block" "public-access" {
  bucket = aws_s3_bucket.ctd-s3-bucket.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "bucket-policy" {
  bucket = aws_s3_bucket.ctd-s3-bucket.id
  policy = data.aws_iam_policy_document.allow-public-access-on-bucket.json
}

data "aws_iam_policy_document" "allow-public-access-on-bucket" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.ctd-s3-bucket.arn}/*"]
  }
}

resource "aws_s3_bucket_website_configuration" "ctd-website" {
  bucket = aws_s3_bucket.ctd-s3-bucket.id
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "error.html"
  }
}

resource "aws_cloudwatch_log_group" "api_logs" {
  name              = "/aws/http-api/ctd-http-api"
  retention_in_days = 7
  tags = {
    Name = var.project_tag
  }
}

resource "aws_iam_role" "ctd-lambda" {
  name = "ctd-lambda"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
  tags = {
    Name = var.project_tag
  }
}

resource "aws_iam_role_policy_attachment" "ctd-dynamodb-write" {
  role       = aws_iam_role.ctd-lambda.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

resource "aws_iam_role_policy_attachment" "ctd-logs" {
  role       = aws_iam_role.ctd-lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "ctd-api" {
  filename         = "lambda_function.zip"
  function_name    = var.lambda_function_name
  role             = aws_iam_role.ctd-lambda.arn
  handler          = "app.handler"
  runtime          = var.lambda_runtime
  timeout          = 10
  source_code_hash = filebase64sha256("lambda_function.zip")
  tags = {
    Name = var.project_tag
  }
}

resource "aws_lambda_permission" "allow_api_gateway_invoke" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ctd-api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.ctd-api-gw.execution_arn}/*/*"
}

resource "aws_apigatewayv2_api" "ctd-api-gw" {
  name          = "ctd-http-api"
  protocol_type = "HTTP"
  description   = "The HTTP API Gateway for Connecting The Dots"
  tags = {
    Name = var.project_tag
  }
}

resource "aws_apigatewayv2_integration" "ctd-api-gw-int" {
  api_id                 = aws_apigatewayv2_api.ctd-api-gw.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.ctd-api.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "ctd-api-gw-route" {
  api_id    = aws_apigatewayv2_api.ctd-api-gw.id
  route_key = "ANY /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.ctd-api-gw-int.id}"
}

resource "aws_apigatewayv2_stage" "ctd-api-gw-stage" {
  api_id      = aws_apigatewayv2_api.ctd-api-gw.id
  name        = "$default"
  auto_deploy = true
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_logs.arn
    format = jsonencode({
      requestId               = "$context.requestId",
      ip                      = "$context.identity.sourceIp",
      routeKey                = "$context.routeKey",
      status                  = "$context.status",
      errorMessage            = "$context.error.message",
      integrationErrorMessage = "$context.integration.error"
    })
  }
  tags = {
    Name = var.project_tag
  }
}

resource "aws_dynamodb_table" "ctd-db" {
  name         = "ConnectingTheDotsDBTable"
  hash_key     = "email"
  billing_mode = "PAY_PER_REQUEST"
  attribute {
    name = "email"
    type = "S"
  }
  tags = {
    Name = var.project_tag
  }
}

resource "aws_cognito_user_pool" "ctd_user_pool" {
  name = "ctd-user-pool"
  username_attributes = ["email"]
  auto_verified_attributes = ["email"]
  email_verification_message = "Hi {username}, please verify your email using this code: {####}."
}

resource "aws_cognito_user_pool_client" "ctd_client_pool" {
  name                                 = "ctd-client-pool"
  user_pool_id                         = aws_cognito_user_pool.ctd_user_pool.id
  allowed_oauth_flows_user_pool_client = true
  generate_secret                      = false
  allowed_oauth_flows  = ["code"]
  allowed_oauth_scopes = ["email", "openid", "profile"]
  callback_urls = ["https://www.connectingthedotscorp.com"]
  logout_urls   = ["https://www.connectingthedotscorp.com"]
  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]
}

resource "aws_route53_record" "ctd_auth_record" {
  zone_id = "Z00713722PLNXU0MA2D5C"
  name    = "auth.connectingthedotscorp.com"
  type    = "CNAME"
  ttl     = 300
  records = ["d1mdx2gg4onm4t.cloudfront.net"]
}
