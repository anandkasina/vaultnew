provider vault{
  address = "http://34.71.251.34:8200"
  token = "hvs.0F8m6ealq5Ij0I10TfUoR0L4"

}

resource "vault_aws_secret_backend" "aws" {
  access_key = "AKIAWCLFHFHVL5JXIBGC"
  secret_key = "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"
  path = "awsvaulpocnew1"
}

resource "vault_aws_secret_backend_role" "role" {
  backend = vault_aws_secret_backend.aws.path
  name    = "test2"
  credential_type = "iam_user"

  policy_document = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "iam:CreateAccessKey",
        "iam:DeleteAccessKey",
        "iam:GetUser",
        "iam:DeleteUser",
        "iam:ListAccessKeys",
        "iam:ListAttachedUserPolicies",
        "iam:ListGroupsForUser",
        "iam:ListUserPolicies",
        "iam:RemoveUserFromGroup"
      ],
      "Resource": [
        "arn:aws:iam::ACCOUNT-ID-WITHOUT-HYPHENS:user/vault-root-*",
        "arn:aws:iam::ACCOUNT-ID-WITHOUT-HYPHENS:user/root-for-vault"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "iam:AttachUserPolicy",
        "iam:CreateUser",
        "iam:DeleteUserPolicy",
        "iam:DetachUserPolicy",
        "iam:PutUserPolicy"
      ],
      "Resource": [
        "arn:aws:iam::${AWS_ACCOUNT_ID}:user/vault-root-*"
      ],
      "Condition": {
        "StringEquals": {
          "iam:PermissionsBoundary": [
            "arn:aws:iam::417360980458:policy/vault-aws-permission-boundary"
          ]
        }
      }
    }
  ]
}
EOT
}

# generally, these blocks would be in a different module
data "vault_aws_access_credentials" "creds" {
  backend = vault_aws_secret_backend.aws.path
  role    = vault_aws_secret_backend_role.role.name
}
#error here
provider "aws" {
  access_key = data.vault_aws_access_credentials.creds.access_key
  secret_key = data.vault_aws_access_credentials.creds.secret_key
  region = "us-east-1"
}

resource "aws_s3_bucket" "bucket" {
  bucket = "bucket11"
  acl    = "public-read"
}

