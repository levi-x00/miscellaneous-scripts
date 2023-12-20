# AWS Lambda Template

## Some Prerequisites to follow before trying this lambda function template

### 1. Configure AWS Profile

to configure a profile on your local

```
aws configure --profile <your-profile-name>
```

then update ```variables.tf``` for this part based on your profile name

```
variables "profile" {
  type    = string
  default = "<your-profile-name>"
}
```
### 2. Apply The Terraform
```
terraform init
terraform plan
terraform apply -auto-approve
```
