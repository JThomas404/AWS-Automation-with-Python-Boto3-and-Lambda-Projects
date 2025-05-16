resource "aws_api_gateway_rest_api" "ctdc-api" {
  name        = "ctdc-api"
  description = "API Gateway for Connecting The Dots Lambda"

  tags = {
    Name = var.project_tag
  }
}

resource "aws_cloudwatch_log_group" "api_gw_logs" {
  name              = "/aws/api-gateway/ctdc-api"
  retention_in_days = 14
}

resource "aws_iam_role" "apigw_cloudwatch_role" {
  name = "APIGatewayCloudWatchLogsRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "apigateway.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "apigw_cloudwatch_role_attach" {
  role       = aws_iam_role.apigw_cloudwatch_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

resource "aws_api_gateway_account" "ctdc-account" {
  cloudwatch_role_arn = aws_iam_role.apigw_cloudwatch_role.arn
}

resource "aws_lambda_permission" "ctdc-api-gateway-permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ctdc-lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.ctdc-api.execution_arn}/*/*"
}

resource "aws_api_gateway_resource" "ctdc-contact-resource" {
  rest_api_id = aws_api_gateway_rest_api.ctdc-api.id
  parent_id   = aws_api_gateway_rest_api.ctdc-api.root_resource_id
  path_part   = "contact"
}

resource "aws_api_gateway_method" "ctdc-contact-post" {
  rest_api_id   = aws_api_gateway_rest_api.ctdc-api.id
  resource_id   = aws_api_gateway_resource.ctdc-contact-resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "ctdc-contact-post-integration" {
  rest_api_id             = aws_api_gateway_rest_api.ctdc-api.id
  resource_id             = aws_api_gateway_resource.ctdc-contact-resource.id
  http_method             = "POST"
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.ctdc-lambda.invoke_arn
}

resource "aws_api_gateway_method_response" "ctdc-contact-post-response" {
  rest_api_id = aws_api_gateway_rest_api.ctdc-api.id
  resource_id = aws_api_gateway_resource.ctdc-contact-resource.id
  http_method = "POST"
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Headers" = true
  }
}

resource "aws_api_gateway_integration_response" "ctdc-contact-post-integration-response" {
  rest_api_id = aws_api_gateway_rest_api.ctdc-api.id
  resource_id = aws_api_gateway_resource.ctdc-contact-resource.id
  http_method = "POST"
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'",
    "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'",
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type'"
  }

  depends_on = [
    aws_api_gateway_method_response.ctdc-contact-post-response,
    aws_api_gateway_integration.ctdc-contact-post-integration
  ]
}

resource "aws_api_gateway_method" "ctdc-contact-options" {
  rest_api_id   = aws_api_gateway_rest_api.ctdc-api.id
  resource_id   = aws_api_gateway_resource.ctdc-contact-resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "ctdc-contact-options-integration" {
  rest_api_id = aws_api_gateway_rest_api.ctdc-api.id
  resource_id = aws_api_gateway_resource.ctdc-contact-resource.id
  http_method = "OPTIONS"
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "ctdc-contact-options-response" {
  rest_api_id = aws_api_gateway_rest_api.ctdc-api.id
  resource_id = aws_api_gateway_resource.ctdc-contact-resource.id
  http_method = "OPTIONS"
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Headers" = true
  }
}

resource "aws_api_gateway_integration_response" "ctdc-contact-options-integration-response" {
  rest_api_id = aws_api_gateway_rest_api.ctdc-api.id
  resource_id = aws_api_gateway_resource.ctdc-contact-resource.id
  http_method = "OPTIONS"
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'",
    "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'",
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type'"
  }

  depends_on = [
    aws_api_gateway_integration.ctdc-contact-options-integration
  ]
}

# ---------------------- /userdata Resource ----------------------
resource "aws_api_gateway_resource" "ctdc-userdata-resource" {
  rest_api_id = aws_api_gateway_rest_api.ctdc-api.id
  parent_id   = aws_api_gateway_rest_api.ctdc-api.root_resource_id
  path_part   = "userdata"
}

resource "aws_api_gateway_method" "ctdc-userdata-get" {
  rest_api_id   = aws_api_gateway_rest_api.ctdc-api.id
  resource_id   = aws_api_gateway_resource.ctdc-userdata-resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "ctdc-userdata-get-integration" {
  rest_api_id             = aws_api_gateway_rest_api.ctdc-api.id
  resource_id             = aws_api_gateway_resource.ctdc-userdata-resource.id
  http_method             = "GET"
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.ctdc-lambda.invoke_arn
}

resource "aws_api_gateway_method_response" "ctdc-userdata-get-response" {
  rest_api_id = aws_api_gateway_rest_api.ctdc-api.id
  resource_id = aws_api_gateway_resource.ctdc-userdata-resource.id
  http_method = "GET"
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_integration_response" "ctdc-userdata-get-integration-response" {
  rest_api_id = aws_api_gateway_rest_api.ctdc-api.id
  resource_id = aws_api_gateway_resource.ctdc-userdata-resource.id
  http_method = "GET"
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }

  depends_on = [
    aws_api_gateway_method_response.ctdc-userdata-get-response,
    aws_api_gateway_integration.ctdc-userdata-get-integration
  ]
}

resource "aws_api_gateway_method" "ctdc-userdata-options" {
  rest_api_id   = aws_api_gateway_rest_api.ctdc-api.id
  resource_id   = aws_api_gateway_resource.ctdc-userdata-resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "ctdc-userdata-options-integration" {
  rest_api_id = aws_api_gateway_rest_api.ctdc-api.id
  resource_id = aws_api_gateway_resource.ctdc-userdata-resource.id
  http_method = "OPTIONS"
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "ctdc-userdata-options-response" {
  rest_api_id = aws_api_gateway_rest_api.ctdc-api.id
  resource_id = aws_api_gateway_resource.ctdc-userdata-resource.id
  http_method = "OPTIONS"
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Headers" = true
  }
}

resource "aws_api_gateway_integration_response" "ctdc-userdata-options-integration-response" {
  rest_api_id = aws_api_gateway_rest_api.ctdc-api.id
  resource_id = aws_api_gateway_resource.ctdc-userdata-resource.id
  http_method = "OPTIONS"
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'",
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
  }
}

# ---------------------- Deployment & Stage ----------------------
resource "aws_api_gateway_deployment" "ctdc-api-deployment" {
  rest_api_id = aws_api_gateway_rest_api.ctdc-api.id

  lifecycle {
    create_before_destroy = true
  }

  triggers = {
    redeploy = timestamp()
  }

  depends_on = [
    aws_api_gateway_integration.ctdc-contact-post-integration,
    aws_api_gateway_integration_response.ctdc-contact-post-integration-response,
    aws_api_gateway_integration_response.ctdc-contact-options-integration-response,
    aws_api_gateway_integration.ctdc-userdata-get-integration,
    aws_api_gateway_integration_response.ctdc-userdata-get-integration-response,
    aws_api_gateway_integration_response.ctdc-userdata-options-integration-response
  ]
}

resource "aws_api_gateway_stage" "ctdc-api-stage" {
  rest_api_id   = aws_api_gateway_rest_api.ctdc-api.id
  deployment_id = aws_api_gateway_deployment.ctdc-api-deployment.id
  stage_name    = "prod"

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw_logs.arn
    format = jsonencode({
      requestId    = "$context.requestId"
      status       = "$context.status"
      protocol     = "$context.protocol"
      ip           = "$context.identity.sourceIp"
      user         = "$context.identity.user"
      requestTime  = "$context.requestTime"
      resourcePath = "$context.resourcePath"
    })
  }

  xray_tracing_enabled = true

  tags = {
    Name = var.project_tag
  }
}
