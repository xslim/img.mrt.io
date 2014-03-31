describe 'Flickr', ->

  describe 'Photo', ->  
    it 'should respond with json', (done) ->
      chai.request(baseUrl)
        .get('/flickr/9293264066/json')
        .res (res) ->
          res.should.have.status 200
          res.should.have.header('content-type', 'application/json')
          res.should.be.JSON
          console.log res
          done()
    
    
    
#/hubot/ping