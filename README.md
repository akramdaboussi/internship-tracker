# internship-tracker

Three-tier internship application tracker, deployed on AWS with Terraform.

**Status:** work in progress : infrastructure foundations.

## Architecture

- **Frontend:** React, served from S3 via CloudFront
- **API:** containerised, running on ECS Fargate behind an ALB
- **Database:** PostgreSQL on RDS, in private subnets

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
```

## Cost

Running continuously, this stack costs roughly €75/month.
Destroy it when not in use: `terraform destroy`.