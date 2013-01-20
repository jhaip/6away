git add -A
git commit -m "saving"
git push heroku master
heroku open
heroku logs --source app --tail