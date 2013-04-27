#!/bin/bash

./modules.sh

cp -p index.html out

cd out
git add .

git diff --cached --exit-code --quiet
if [[ $? -eq 1 ]]; then
    git commit -m'update' --author='nodepkgs cronjob <nodepkgs@homohacker.com>'
    GIT_SSH=ssh_cron git push origin gh-pages --quiet
fi