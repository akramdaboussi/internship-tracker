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
- Four subnets across two availability zones : two public, two private
- Internet Gateway for inbound and outbound traffic in public subnets
- Single NAT Gateway in `public-a`, providing outbound-only access for private subnets
- Two route tables, one per tier, with explicit subnet associations

**Database**
- PostgreSQL on RDS, `db.t4g.micro`, single-AZ, encrypted at rest
- Placed in private subnets via a dedicated DB subnet group
- Not publicly accessible; reachable only on port 5432 from the ECS task security group
- Master credentials generated and rotated by RDS, stored in Secrets Manager

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

Two resources carry an hourly charge: the NAT Gateway (~$32/month) and the RDS
instance (~$15/month). Everything else — VPC, subnets, route tables, Internet
Gateway, security groups — is free. Left running, the current stack costs
roughly $47/month; destroyed between sessions, a few cents per hour.


## Limitations and possible improvements

**Single NAT Gateway** : The NAT Gateway lives in `public-a`. If availability
zone A goes down, it disappears with it and both private subnets lose outbound
access, including `private-b`, which sits in a healthy zone. No new Fargate task
could start, since pulling an image from ECR requires outbound connectivity.
A production setup would run one NAT Gateway per zone, with a dedicated private
route table each, at twice the cost.

**Single-AZ database** : The RDS instance runs in one availability zone; the DB
subnet group spans two only because AWS requires it. If that zone fails, the
database is down until restored from backup, one to two hours. `multi_az = true`
would add a standby with automatic failover, at twice the cost.

**No final snapshot on destroy** : `skip_final_snapshot = true` suits a project
torn down after every session. In production it would be reversed : the final
snapshot is the last defence against an accidental `destroy`.

**Application connects as the master user** : No dedicated application role. A
production setup would create a restricted user with read/write access to the
application tables only.