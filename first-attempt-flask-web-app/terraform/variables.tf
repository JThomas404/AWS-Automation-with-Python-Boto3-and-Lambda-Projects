variable "region" {
  description = "The AWS region to deploy the resources"
  type        = string
  default     = "us-east-1"

}

variable "lambda_function_name" {
  description = "The name of the AWS Lambda function"
  default     = "ctd-api"
}

variable "lambda_runtime" {
  description = "The Python runtime environment for the Lambda function"
  default     = "python3.12"
}

variable "project_tag" {
  description = "Tag value used for identifying project resources"
  default     = "ctd-api"
}
