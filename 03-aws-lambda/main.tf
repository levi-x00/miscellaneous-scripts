resource "aws_cloudwatch_log_group" "lambda_log" {
  name              = "/aws/lambda/${var.lambda_name}"
  retention_in_days = 30
}

resource "random_uuid" "lambda_src_hash" {
  keepers = {
    for filename in setunion(
      fileset("${path.module}/src", "lambda_function.py"),
      fileset("${path.module}/src", "requirements.txt")
    ) :
    filename => filemd5("${path.module}/src/${filename}")
  }
}



resource "null_resource" "lambda_zip" {
  triggers = {
    main_file    = md5(file("${path.module}/src/lambda_function.py"))
    dependencies = md5(file("${path.module}/src/requirements.json"))
  }

  provisioner "local-exec" {
    command = "pip install -r ${path.module}/src/requirements.txt -t ${path.module}/src/"
  }

  #   provisioner "local-exec" {
  #     command = <<EOT
  #       cd lambda && npm install
  #       zip -rq ${var.zip_file} .
  #       hash_value=$(openssl dgst -binary -sha256 ${var.zip_file} | openssl base64)
  #       aws s3 cp ${var.zip_file} s3://${var.s3_bucket_lambda}/lambda/ --metadata hash=$hash_value --only-show-errors
  #       rm -rf ${var.zip_file} node_modules package-lock.json
  #       ls -al
  #       cd ..
  #     EOT
  #   }
}

resource "aws_lambda_function" "this" {
  depends_on = [
    null_resource.lambda_zip,
    aws_cloudwatch_log_group.lambda_log
  ]

  function_name = local.function_name
  handler       = var.handler
  runtime       = var.runtime
  timeout       = var.timeout
  role          = aws_iam_role.lambda_role.arn
  memory_size   = var.memory_size

  filename         = data.archive_file.lambda_src.output_path
  source_code_hash = data.archive_file.lambda_src.output_base64sha256
}
