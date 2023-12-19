locals {
  function_name   = var.lambda_name
  zip_file_lambda = "${path.module}/src/lambda_function.zip"
}
