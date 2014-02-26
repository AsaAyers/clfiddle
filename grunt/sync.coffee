
module.exports =
    main:
        files: [{
            cwd: 'initializr'
            src: '**'
            dest: 'build'
        }, {
            cwd: 'bower_components/jsonlint/web'
            src: '*.js'
            dest: 'build/js/vendor'
        }]


