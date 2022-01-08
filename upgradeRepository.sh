# This script uploads the changes to the repository in only one command

echo "	--> Adding changes"
git add .
read -p "	-->	Enter the message of the commit: " nameCommit
git commit -am $nameCommit
echo "	--> Uploading the changes"
git push
