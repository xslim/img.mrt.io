## API

[![](https://travis-ci.org/xslim/img.mrt.io.svg)](https://travis-ci.org/xslim/img.mrt.io)

### Flickr

- `/flickr/:photoId`, Ex: `http://img.mrt.io/flickr/9293264066/`
- `/flickr/:photoId/:size`, Ex: `http://img.mrt.io/flickr/9293264066/z`
- `/flickr/set/:setId` - JSON, Ex: `http://img.mrt.io/flickr/set/72157642833471825`

### Static Maps

- `/map/:lat,:lon,:zoom/:size`, Ex: `http://img.mrt.io/map/52.70468296296834,5.300731658935547,13/640x200?t=here`

## Developing

Use https://github.com/ddollar/heroku-config to pull / push from `.env`

``` sh
$ heroku plugins:install git://github.com/ddollar/heroku-config.git
$ heroku config:pull
```

`.env` file:

``` sh
REDISTOGO_URL=redis://redistogo
KEY_FLICKR=
KEY_MAPBOX=
KEY_GOOGLE=

```

Run it:

``` sh
$ npm install
$ grunt nodemon

```
