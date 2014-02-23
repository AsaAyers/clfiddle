
module.exports =
    site:
        files: [
            'grunt/**'
            'Gruntfile.coffee'
            'src/**/*.coffee'
            'src/**/*.hbs'
            'less/**/*.less'
            'initializr/**'
        ]
        tasks: ['build']
        options:
            livereload: true
