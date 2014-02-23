
module.exports =
    site:
        files: [
            'grunt/**'
            'Gruntfile.coffee'
            'src/**/*.coffee'
            'less/**/*.less'
            'initializr/**'
        ]
        tasks: ['build']
        options:
            livereload: true
