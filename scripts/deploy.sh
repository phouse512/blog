#!/bin/bash
echo "Running deploy"

pip --version
python --version

echo "Install aws-cli"
pip install awscli --upgrade --user

~/.local/bin/aws --version

echo "Beginning deploy"
~/.local/bin/aws s3 sync /build/_site s3://phizzle.space

