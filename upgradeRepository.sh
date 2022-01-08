echo "Adding changes"
git add .
echo "Doing the commit"
git commit -am $1
echo "Uploading the changes"
git push
