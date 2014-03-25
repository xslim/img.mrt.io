exports.static_link = (lat, lon, zoom, size, provider) ->
  size = size.split("x")
  url = ""
  key = ""
  w = size[0]
  h = size[1]
  provider = "mapbox"  unless provider
  switch provider
    when "mapbox"
      key = "xslim.hgm2p8g2"
      url = "http://api.tiles.mapbox.com"
      url += "/v3/" + key + "/" + lon + "," + lat + "," + zoom + "/" + w + "x" + h + ".png"
    when "google"
      url = "http://maps.googleapis.com"
      url += "/maps/api/staticmap?center=" + lat + "," + lon + "&zoom=" + zoom + "&size=" + w + "x" + h + "&sensor=false"
    when "here"
      url = "http://m.nok.it"
      url += "?w=" + w + "&h=" + h + "&ml=eng&nord&nodot&pip&c=" + lat + "," + lon + "&z=" + zoom + "&f=0"
  url