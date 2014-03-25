## Developing

``` sh
$ npm install
$ grunt nodemon

```

## Deploy

``` sh
$ grunt build
$ NODE_ENV=production node app.js
$ git push heroku master
$ heroku config:set NODE_ENV=production
$ heroku open
```
