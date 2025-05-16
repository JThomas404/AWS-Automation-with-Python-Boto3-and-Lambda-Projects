resource "aws_cognito_user_pool" "ctdc-user-pool" {
  name = "ConnectingTheDotsCorpUserPool"

  auto_verified_attributes = ["email"]
  username_attributes      = ["email"]

  admin_create_user_config {
    allow_admin_create_user_only = false
  }

  tags = {
    Name = var.project_tag
  }
}

resource "aws_cognito_user_pool_client" "ctdc-user-pool-client" {
  name         = "ctdc-user-pool-client"
  user_pool_id = aws_cognito_user_pool.ctdc-user-pool.id

  allowed_oauth_flows          = ["code"]
  allowed_oauth_scopes         = ["email", "openid", "profile"]
  supported_identity_providers = ["COGNITO", "Google"]

  callback_urls = ["https://www.connectingthedotscorp.com/dashboard.html"]
  logout_urls   = ["https://www.connectingthedotscorp.com"]

  allowed_oauth_flows_user_pool_client = true
  generate_secret                      = false
}

resource "aws_cognito_identity_provider" "ctdc-identity-provider" {
  user_pool_id  = aws_cognito_user_pool.ctdc-user-pool.id
  provider_name = "Google"
  provider_type = "Google"

  provider_details = {
    authorize_scopes = "email"
    client_id        = "64476090446-qid9ni635fgm6seipe22rusrt0ip05oi.apps.googleusercontent.com"
    client_secret    = "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"
  }


  attribute_mapping = {
    email    = "email"
    username = "sub"
  }
}