#!/bin/sh

git add .
git commit -m 'auto commit'
git push origin master
hexo g && hexo d
