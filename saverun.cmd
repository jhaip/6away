git add -A
git commit -m $1
git push heroku master
heroku open
heroku logs --source app --tail