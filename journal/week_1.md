# Terraform Beginner Bootcamp 2023 - Week 1

## Creating a bucket holding the Terra House

We need to store our Terra House website in an S3 bucket. 

- Let's create one called `terra-house-bucket`through the CLI:

```bash
aws s3api create-bucket --bucket terra-house-bucket
```
- Now, we can put our HTML page into the bucket:

```bash
aws s3 cp public.html s3://terra-house-bucket/index.html
```
- To make that web page accessible, we must make it public (not recommended) or make it accessible through a CloudFront distribution. That one will have our s3 bucket as **origin** with a control setting and we'll need to set a **bucket policy** on the bucket.

```json
{
        "Version": "2008-10-17",
        "Id": "PolicyForCloudFrontPrivateContent",
        "Statement": [
            {
                "Sid": "AllowCloudFrontServicePrincipal",
                "Effect": "Allow",
                "Principal": {
                    "Service": "cloudfront.amazonaws.com"
                },
                "Action": "s3:GetObject",
                "Resource": "arn:aws:s3:::terra-house-bucket/*",
                "Condition": {
                    "StringEquals": {
                      "AWS:SourceArn": "arn:aws:cloudfront::171653636382:distribution/EZRCSQ1OQXHZV"
                    }
                }
            }
        ]
      }
```

## Fixing Tags

[How to Delete Local and Remote Tags on Git](https://devconnected.com/how-to-delete-local-and-remote-tags-on-git/)

- To locally delete a tag:
```sh
git tag -d <tag_name>
```

- To remotely delete tag:

```sh
git push --delete origin tagname
```
- Checkout the commit that you want to retag. Grab the sha from your Github history.

```sh
git checkout <SHA>
git tag M.M.P
git push --tags
git checkout main
```

## Root Module Structure

We will restructure the root module as follows regarding the recommended standard by Hashicorp:

```
PROJECT_ROOT
│
├── main.tf                 # everything else.
├── variables.tf            # stores the structure of input variables
├── terraform.tfvars        # the data of variables we want to load into our terraform project
├── providers.tf            # defined required providers and their configuration
├── outputs.tf              # stores our outputs
└── README.md               # required for root modules
```

[Standard Module Structure](https://developer.hashicorp.com/terraform/language/modules/develop/structure)

- `main.tf`:

```hcl
# https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string
resource "random_string" "bucket_name" {
  lower = true
  upper = false
  length   = 32
  special  = false
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
resource "aws_s3_bucket" "example" {
  # Bucket Naming Rules
  #https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucketnamingrules.html?icmpid=docs_amazons3_console
  bucket = random_string.bucket_name.result

  tags = {
    UserUuid = var.user_uuid
  }
}
```

- `outputs.tf`:

```hcl
output "random_bucket_name" {
  value = random_string.bucket_name.result
}
```

- `providers.tf`:

```hcl
terraform {
  required_providers {
    random = {
      source = "hashicorp/random"
      version = "3.5.1"
    }
    aws = {
      source = "hashicorp/aws"
      version = "5.16.2"
    }
  }
}

provider "aws" {
}
provider "random" {
  # Configuration options
}
```

- `variables.tf`:

```hcl
variable "user_uuid" {
  description = "The UUID of the user"
  type        = string
  validation {
    condition        = can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$", var.user_uuid))
    error_message    = "The user_uuid value is not a valid UUID."
  }
}
```

- `terraform.tfvars`:

```hcl
user_uuid = "92e7bb7c-340e-4481-b069-79b4f94e9dce"
```

## Terraform and Input Variables

### Terraform Cloud Variables

In terraform; we can set two kind of variables:
- **Enviroment Variables** - those you would set in your bash terminal eg. AWS credentials
- **Terraform Variables** - those that you would normally set in your tfvars file

We can set Terraform Cloud variables to be sensitive so they are not shown visibly in the UI.

### Loading Terraform Input Variables

When variables are declared in the root module of your configuration, they can be set in a number of ways:

- In a Terraform Cloud workspace.
- Individually, with the -var command line option.
- In variable definitions (.tfvars) files, either specified on the command line or automatically loaded.
- As environment variables.

[Terraform Input Variables](https://developer.hashicorp.com/terraform/language/values/variables)

### var flag

We can use the `-var` flag to set an input variable or override a variable in the tfvars file eg. `terraform -var user_uuid="my-user_id"`. It can be used with the `terraform plan` and `terraform apply` commands:

### var-file flag

To set lots of variables, it is more convenient to specify their values in a variable definitions file (with a filename ending in either .tfvars or .tfvars.json) and then specify that file on the command line with `-var-file`:

`terraform apply -var-file="testing.tfvars"`

### terraform.tfvars and auto.tfvars

Terraform also automatically loads a number of variable definitions files if they are present:

- Files named exactly `terraform.tfvars` or `terraform.tfvars.json`.
- Any files with names ending in `.auto.tfvars` or `.auto.tfvars.json`.

Files whose names end with **.json** are parsed instead as JSON objects, with the root object properties corresponding to variable names:

```json
{
  user_uuid : "my-user_id"
}
```

### Order of terraform variables

Terraform uses a specific order of precedence when determining the value of a variable. If the same variable is assigned multiple values, Terraform will use the value of highest precedence, overriding any other values. Below is the precedence order starting from the highest priority to the lowest.

1. `Environment variables` (TF_VAR_variable_name)
2. The `terraform.tfvars` file
3. The `terraform.tfvars.json` file
4. Any .`auto.tfvars` or `.auto.tfvars.json` files, processed in lexical order of their filenames.
5. Any `-var` and `-var-file` options on the command line, in the order they are provided.
6. Variable `defaults`

## Dealing With Configuration Drift

## What happens if we lose our state file?

- If you lose your state file, you most likely have to tear down all your cloud infrastructure **manually**.

- You can use `terraform import` but it won't work for all cloud resources. You need check the terraform providers documentation for which resources support import.

### Fix Missing Resources with Terraform Import

`terraform import aws_s3_bucket.[bucket resource name] [bucket-name]`

[Terraform Import](https://developer.hashicorp.com/terraform/cli/import)
[AWS S3 Bucket Import](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket#import)

### Fix Manual Configuration

If someone goes and delete or modifies cloud resource manually through ClickOps and we run `terraform plan`, it will attempt to put our infrastructure back into the expected state fixing Configuration Drift.