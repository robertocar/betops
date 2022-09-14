git init && git add -A && git commit -m "initial push"
git config --global credential.https://source.developers.google.com.helper gcloud.sh
git remote add google $1
(gcloud auth login) -and (git push --all google)

git init
git add -A 
git commit -m "initial push"
git config --global credential.https://source.developers.google.com.helper gcloud.sh
git remote add google https://source.developers.google.com/p/betops/r/devops-repo
gcloud auth login 
git push --all google

(gcloud init) -and (git config --global credential.https://source.developers.google.com.helper gcloud.cmd)

urls = {
  "app" = "https://devops-jy3id56vgq-rj.a.run.app"
  "repo" = "https://source.developers.google.com/p/betops/r/devops-repo"
}
