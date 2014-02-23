
module.exports =
    options:
        transform: [
            'coffeeify'
            'browserify-handlebars'
        ]
        debug: true
    colormycraft:
        files:
            "build/js/main.js": [
                'src/main.coffee'
            ]
