# internship-tracker

Three-tier internship application tracker, deployed on AWS with Terraform.

**Status:** work in progress : infrastructure foundations.

## Architecture

- **Frontend:** React, served from S3 via CloudFront
- **API:** containerised, running on ECS Fargate behind an ALB
- **Database:** PostgreSQL on RDS, in private subnets

# Current state

The networking layer is provisioned and managed by Terraform:

- VPC `10.42.0.0/16` with DNS support and hostnames enabled
- Four subnets across two availability zones — two public, two private
- Internet Gateway for inbound and outbound traffic in public subnets
- Single NAT Gateway in `public-a`, providing outbound-only access for private subnets
- Two route tables, one per tier, with explicit subnet associations

## Repository layout

| Path | Contents |
|---|---|
| `terraform/` | Infrastructure as code |
| `app/` | Application source |
| `scripts/` | Operational tooling |

## Requirements

- Terraform >= 1.10
- AWS CLI, configured
- An S3 bucket for remote state

## Usage

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

Tear down when you're done:

```bash
terraform destroy
```

## Cost

Networking resources are free except the NAT Gateway, billed at roughly
$0.045/hour plus data processed, about $32/month if left running.
Everything else in this layer (VPC, subnets, route tables, Internet Gateway)
incurs no charge.

## Limitations and possible improvements

**Single NAT Gateway** : The NAT Gateway lives in `public-a`. If availability
zone A goes down, it disappears with it and both private subnets lose outbound
access, including `private-b`, which sits in a healthy zone. No new Fargate task
could start, since pulling an image from ECR requires outbound connectivity.
A production setup would run one NAT Gateway per zone, with a dedicated private
route table each, at twice the cost.