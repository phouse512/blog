#!/usr/bin/env bash
echo "Running in local development mode."
set -e # halt script on error

cd /srv/jekyll
echo "Running gem installer"
gem install -V bundler:1.16.1
echo "Jekyll build"
jekyll build
# htmlproofer --http-status-ignore 403 ./_site
jekyll serve

