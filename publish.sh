#!/bin/bash

jekyll build
mv _site/ /tmp/
git checkout master
rm -r *
cp -r /tmp/_site/* .
rm -r /tmp/_site/
git add . -A
git commit -am'publish'
