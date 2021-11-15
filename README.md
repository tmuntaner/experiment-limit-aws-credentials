# Experiment - limit-aws-creds-to-account

This was an experiment to see if we could limit an AWS IAM user's credentials to an account.

**Findings:**

* It's possible to limit AWS credentials to a VPC through a VPC endpoint. This is because we can filter our traffic through it and use `aws:SourceVpce` in our IAM conditional.

## Useful Links

* https://docs.aws.amazon.com/AmazonS3/latest/userguide/example-bucket-policies-vpc-endpoint.html#example-bucket-policies-restrict-accesss-vpc-endpoint
* https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_condition-keys.html#condition-keys-sourcevpce

## Run the Test

1. Apply the terraform code:
   ```bash
   cd terraform
   terraform init
   terraform apply
   ```
2. Go to the AWS console and generate IAM credentials for the `experiment-user`.
3. SSH into the test server. Terraform should have given you its DNS name in its output.
4. Export the generated IAM credentials in your shell on the test server.
5. Run the following test:
    ```bash
    aws ec2 describe-instances --region=eu-central-1
    ```
6. Run the test outside the VPC (it shouldn't work).
