# This script uploads the changes to the repository in only one command

#!/bin/bash

echo " --> Adding changes"
git add .
echo ""
read -p " -->	Enter the message of the commit: " nameCommit
git commit -am $nameCommit
echo ""
echo " --> Uploading the changes"
git push
