
module.exports = (grunt) ->
    require('load-grunt-config')(grunt)


    grunt.registerTask 'build', [
        'sync'
        'less'
        'browserify'
    ]

    grunt.registerTask 'default', [
        'clean:build'
        'build'
        'connect'
        'watch'
    ]


