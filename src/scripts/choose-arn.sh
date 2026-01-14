#! /bin/bash -ex

# This script is used to choose the ARN of the AWS account you want to connect to.

arn() {
  case $1 in
    "audit") echo "arn:aws:iam::116429877138:role/circleci-oidc-provider-aws"
    ;;
    "log") echo "arn:aws:iam::442797457434:role/circleci-oidc-provider-aws"
    ;;
    "wrk") echo "arn:aws:iam::796973507941:role/circleci-oidc-provider-aws"
    ;;
    "dev") echo "arn:aws:iam::927966219271:role/circleci-oidc-provider-aws"
    ;;
    "prd") echo "arn:aws:iam::518350385672:role/circleci-oidc-provider-aws"
    ;;
    "tbp") echo "arn:aws:iam::592159235076:role/circleci-oidc-provider-aws"
    ;;
    "towner") echo "arn:aws:iam::992382483259:role/circleci-oidc-provider-aws"
    ;;
    *) echo "Invalid account"
    exit 1
    ;;
  esac
  exit 0
}

echo "export OIDC_ROLE_ARN=$(arn $AWS_LOGIN_ACCOUNT)" >> $BASH_ENV
echo "export AWS_ECR_REGISTRY_ID=$(arn $AWS_LOGIN_ACCOUNT | awk -F: '{ print $5 }')" >> $BASH_ENV
