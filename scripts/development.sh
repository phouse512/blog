#!/usr/bin/env bash
echo "Running in local development mode."
set -e # halt script on error

cd /srv/jekyll
gem install bundler:1.16.1
jekyll build
# htmlproofer --http-status-ignore 403 ./_site
jekyll serve

