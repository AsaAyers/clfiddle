$tokens = $('#tokens')

module.exports = (code) ->
    template = require './templates/tokens.hbs'

    context =
        # Using arrays in Handlebars doesn't seem to work well, so I'm
        # converting each token to an object.
        tokens: CoffeeScript.tokens(code).map (token) ->
            objToken = {}

            [ objToken.type, objToken.value, objToken.location] = token
            # Tokens are arrays that should have 3 values, but sometimes may
            # also have extra properties attached.
            for key, value of token when key not in ['0', '1', '2']
                objToken.extra ?= {}
                objToken.extra[key] = value

            if objToken.extra
                objToken.extra = JSON.stringify(objToken.extra, undefined, 2)
            objToken

    html = template(context)
    $tokens.html html
