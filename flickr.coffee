log = false

flickr_img_url = (id, size, use_flickr, secret, server, farm) ->
  console.log "Getting info #{id}/#{size}, using_flickr: #{use_flickr}" if log
  if size.length is 0
    size = ""
  else
    if (use_flickr)
      size = "_" + size
  if (use_flickr)
    "http://farm" + farm + ".staticflickr.com/" + server + "/" + id + "_" + secret + size + ".jpg"
  else
    "http://img.mrt.io/flickr/" + id + "/" + size

flickr_parsePhoto = (photo, use_flickr, opts) ->
  console.log "Parsing Photo #{photo.id}, using_flickr: #{use_flickr}" if log
  opts ?= {}
  title = photo.title._content ? photo.title
  title = opts.title ? title
  photo.owner ?=  {}
  owner = opts.owner ? photo.owner.username
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
  pathalias = photo.pathalias ? photo.owner.path_alias
  url = "http://www.flickr.com/photos/" + pathalias + "/" + photo.id
  title = ""  if title is "image"
  data =
    title: title
    owner: owner
    tags: tags
    link: url
    url_sq: flickr_img_url(photo.id, "sq", use_flickr, photo.secret, photo.server, photo.farm)
    url_s: flickr_img_url(photo.id, "s", use_flickr, photo.secret, photo.server, photo.farm)
    url_q: flickr_img_url(photo.id, "q", use_flickr, photo.secret, photo.server, photo.farm)
    url_t: flickr_img_url(photo.id, "t", use_flickr, photo.secret, photo.server, photo.farm)
    url_m: flickr_img_url(photo.id, "m", use_flickr, photo.secret, photo.server, photo.farm)
    url_n: flickr_img_url(photo.id, "n", use_flickr, photo.secret, photo.server, photo.farm)
    url:   flickr_img_url(photo.id, "", use_flickr, photo.secret, photo.server, photo.farm)
    url_z: flickr_img_url(photo.id, "z", use_flickr, photo.secret, photo.server, photo.farm)
    url_b: flickr_img_url(photo.id, "b", use_flickr, photo.secret, photo.server, photo.farm)
    url_l: flickr_img_url(photo.id, "l", use_flickr, photo.secret, photo.server, photo.farm)
    url_o: flickr_img_url(photo.id, "o", use_flickr, photo.originalsecret, photo.server, photo.farm)

  data

exports.getPhotoInfo = (photo_id, size = "", callback) ->
  console.log "getPhotoInfo #{photo_id}" if log
  key = process.env.KEY_FLICKR
  url = "https://api.flickr.com/services/rest/?method=flickr.photos.getInfo&api_key=" + key + "&photo_id=" + photo_id + "&format=json&nojsoncallback=1"
  # console.log url
  if size.length is 0
    size = "url"
  else
    size = "url_" + size
  getJSON url, (json) ->
    return callback(null) unless json.photo?
    data = flickr_parsePhoto(json.photo, true)
    if size is "url_json"
      callback data
    else
      callback data[size]


exports.getSetInfo = (set_id, callback) ->
  extras = "original_format%2Ctags%2Co_dims%2Cpath_alias"
  key = process.env.KEY_FLICKR
  my_url = "https://api.flickr.com/services/rest/?method=flickr.photosets.getPhotos&api_key=" + key + "&photoset_id=" + set_id + "&extras=" + extras + "&format=json&nojsoncallback=1"
  getJSON my_url, (json) ->
    callback null unless json.photoset?
    photos = json.photoset.photo
    info = json.photoset
    data = []
    for index of photos
      photo = photos[index]
      data.push flickr_parsePhoto(photo, false,
        owner: info.ownername
      )
    callback data
