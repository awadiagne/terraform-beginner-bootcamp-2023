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