#!/usr/bin/env bash
echo "Running website build."
set -e # halt script on error

gem install -V bundler:1.16.1
mkdir -p _site
jekyll build

