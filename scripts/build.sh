#!/usr/bin/env bash
echo "Running website build."
set -e # halt script on error

cd /srv/jekyll
jekyll build

