'use strict';

module.exports = function (grunt) {
    // load all grunt tasks
    require('load-grunt-tasks')(grunt);
    // require('grunt-nodemon')(grunt);

    grunt.initConfig({
      
        nodemon: {
          dev: {
            script: 'app.coffee'
          }
        }
      });

};
