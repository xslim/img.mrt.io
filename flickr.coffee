defaultFor = (arg, val) ->
  (if typeof arg isnt "undefined" then arg else val)

flickr_img_url = (id, size, secret, server, farm) ->
  if size.length is 0
    size = ""
  else
    size = "_" + size
  "http://farm" + farm + ".staticflickr.com/" + server + "/" + id + "_" + secret + size + ".jpg"

flickr_parsePhoto = (photo, opts) ->
  opts = defaultFor(opts, {})
  title = defaultFor(photo.title._content, photo.title)
  title = defaultFor(opts.title, title)
  photo.owner = defaultFor(photo.owner, {})
  owner = defaultFor(opts.owner, photo.owner.username)
  tags = ""
  if photo.tags.tag
    tags = photo.tags.tag
    tag_values = []
    for index of tags
      h = tags[index]
      tag_values.push h._content
    tags = tag_values.join(", ")
  else
    tags = photo.tags
  pathalias = defaultFor(photo.pathalias, photo.owner.path_alias)
  url = "http://www.flickr.com/photos/" + pathalias + "/" + photo.id
  title = ""  if title is "image"
  data =
    title: title
    owner: owner
    tags: tags
    link: url
    url: flickr_img_url(photo.id, "", photo.secret, photo.server, photo.farm)
    url_s: flickr_img_url(photo.id, "s", photo.secret, photo.server, photo.farm)
    url_z: flickr_img_url(photo.id, "z", photo.secret, photo.server, photo.farm)
    url_b: flickr_img_url(photo.id, "b", photo.secret, photo.server, photo.farm)
    url_o: flickr_img_url(photo.id, "o", photo.originalsecret, photo.server, photo.farm)

  data

flickr_api_key = "a80bf5179799d078a4cdecd8dd1ae1cf"
exports.getPhotoInfo = (photo_id, size, callback) ->
  size = defaultFor(size, "")
  url = "http://api.flickr.com/services/rest/?method=flickr.photos.getInfo&api_key=" + flickr_api_key + "&photo_id=" + photo_id + "&format=json&nojsoncallback=1"
  if size.length is 0
    size = "url"
  else
    size = "url_" + size
  getJSON url, (json) ->
    data = flickr_parsePhoto(json.photo)
    if size is "url_json"
      callback data
    else
      callback data[size]


exports.getSetInfo = (set_id, callback) ->
  extras = "original_format%2Ctags%2Co_dims%2Cpath_alias"
  my_url = "http://api.flickr.com/services/rest/?method=flickr.photosets.getPhotos&api_key=" + flickr_api_key + "&photoset_id=" + set_id + "&extras=" + extras + "&format=json&nojsoncallback=1"
  getJSON my_url, (json) ->
    photos = json.photoset.photo
    info = json.photoset
    data = []
    for index of photos
      photo = photos[index]
      data.push flickr_parsePhoto(photo,
        owner: info.ownername
      )
    callback data