
module.exports =
    options:
        transform: [
            'coffeeify'
        ]
        debug: true
    colormycraft:
        files:
            "build/js/main.js": [
                'src/main.coffee'
            ]
