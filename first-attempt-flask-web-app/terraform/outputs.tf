output "api_endpoint" {
  description = "The base URL of the deployed API Gateway"
  value       = aws_apigatewayv2_api.ctd-api-gw.api_endpoint
}
