# This script for Windows uploads the changes to the repositories and upgrades the web

# Uploads the changes to the source repository
Write-Host "     UPGRADING THE SOURCE REPOSITORY" -ForegroundColor DarkGreen
Write-Host "-------------------------------------------------" -ForegroundColor DarkGreen
Write-Host " --> Adding changes" -ForegroundColor DarkGreen
git add .
Write-Host ""
$nameCommit = Read-Host " -->	Enter the message of the commit: "
git commit -am $nameCommit
Write-Host ""
Write-Host " --> Uploading the changes" -ForegroundColor DarkGreen
git push

# Generates the HTML code
Write-Host ""
Write-Host ""
Write-Host "     GENERATING HTML" -ForegroundColor DarkGreen
Write-Host "-------------------------------------------------" -ForegroundColor DarkGreen
bin/publish

# Uploads the changes to the repository that serves the web page
Write-Host ""
Write-Host ""
Write-Host "     UPGRADING THE WEB" -ForegroundColor DarkGreen
Write-Host "-------------------------------------------------" -ForegroundColor DarkGreen
cd _site/
git checkout new_web
# Write-Host "www.javierpzh.es" > CNAME
Set-Content -Path .\CNAME -Value "www.javierpzh.es"
git add .
git commit -am "cambiosweb"
git push
cd ..