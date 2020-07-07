#!/usr/bin/env bash
echo "Running website build."
set -e # halt script on error

cd /srv/jekyll
gem install bundler:1.16.1
mkdir -p _site
jekyll build

