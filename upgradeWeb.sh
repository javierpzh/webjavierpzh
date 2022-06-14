# This script uploads the changes to the repositories and upgrades the web

#!/bin/bash

# Uploads the changes to the source repository
echo "     UPGRADING THE SOURCE REPOSITORY"
echo ""
echo " --> Adding changes"
git add .
echo ""
read -p " -->	Enter the message of the commit: " nameCommit
git commit -am $nameCommit
echo ""
echo " --> Uploading the changes"
git push

# Generates the HTML code
echo ""
echo "     GENERATING HTML"
bin/publish

# Uploads the changes to the repository that serves the web page
echo ""
echo "     UPGRADING THE WEB"
cd _site/
git add .
git commit -am "cambiosweb"
git push
cd ..