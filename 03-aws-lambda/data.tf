data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = [
        "lambda.amazonaws.com"
      ]
    }
  }
}

data "aws_iam_policy_document" "lambda_inline_policy" {
  statement {
    sid = "AllowS3"
    actions = [
      "s3:GetObject"
    ]
    resources = ["*"]
  }
}

data "archive_file" "lambda_src" {
  depends_on = [null_resource.lambda_zip]
  excludes = [
    "__pycache__",
    "venv",
  ]

  source_dir  = "${path.module}/src"
  output_path = "${random_uuid.lambda_src_hash.result}.zip"
  type        = "zip"
}
