
module.exports =
    main:
        files: [{
            cwd: 'initializr'
            src: '**'
            dest: 'build'
        }, {
            cwd: 'bower_components/coffee-script/extras'
            src: 'coffee-script.js'
            dest: 'build/js/vendor'
        }, {
            cwd: 'bower_components/jsonlint/web'
            src: '*.js'
            dest: 'build/js/vendor'
        }]


