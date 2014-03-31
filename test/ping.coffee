describe 'Test test', ->
  
  it 'should respond to ping', (done) ->
    chai.request(baseUrl)
      .get('/ping')
      .res (res) ->
        res.should.have.status 200
        res.should.have.header('content-type', 'text/plain')
        res.text.should.equal('PONG');
        done()
    
    
    
#/hubot/ping