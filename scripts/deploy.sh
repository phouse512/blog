#!/bin/bash
echo "Running deploy"

pip --version
python --version

echo "Install aws-cli"
pip install awscli --upgrade --user

~/.local/bin/aws --version

ls 
ls _build
echo "Beginning deploy"
~/.local/bin/aws s3 sync ./_build s3://phizzle.space
~/.local/bin/aws cloudfront create-invalidation --distribution-id E1HVGFDORPL5AZ --paths /\*

