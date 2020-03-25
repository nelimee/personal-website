#!/usr/bin/sh

START_DIR=$(pwd)
BLOG_DIR=`realpath "$0" | xargs dirname`

cd "$BLOG_DIR"
echo "Updating blog static content..."
hugo
echo "Uploading blog..."
rsync -avz ./public/ ovh:/root/blog/public/
cd "$START_DIR"
