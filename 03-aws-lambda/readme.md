# AWS Lambda Template

## Some Prerequisites to follow before trying this lambda function template

### 1. Create S3 for Tfstate Bucket & Lambda

go to AWS s3 console to create s3 for the tfstate and lambda functions, name them whatever you want as long as they're unique, on my case I'll create s3 bucket with the following bucket policy, from this [source](https://repost.aws/knowledge-center/s3-bucket-policy-for-config-rule)

```json
{
  "Id": "ExamplePolicy",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowSSLRequestsOnly",
      "Action": "s3:*",
      "Effect": "Deny",
      "Resource": [
        "arn:aws:s3:::DOC-EXAMPLE-BUCKET",
        "arn:aws:s3:::DOC-EXAMPLE-BUCKET/*"
      ],
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "false"
        }
      },
      "Principal": "*"
    }
  ]
}
```

### 2. Create DynamoDB table for terraform

to avoid upcoming collieded terraform apply, dynamodb will come in handy

### 3. Apply The Terraform

```terraform
terraform init
terraform plan
terraform apply -auto-approve
```
