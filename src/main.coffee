
# I'm making this global in case people want to poke at it from the console.
window.CoffeeLint = require '../node_modules/coffeelint/lib/coffeelint.js'
_ = require '../bower_components/lodash/dist/lodash.js'

$('#output-tabs a').click (e) ->
    e.preventDefault()
    $(this).tab('show')


$editor = $('.editor')
$ast = $('#ast')
$tokens = $('#tokens')

showTokens = (tokens) ->
    template = require './templates/tokens.hbs'

    context =
        # Using arrays in Handlebars doesn't seem to work well, so I'm
        # converting each token to an object.
        tokens: tokens.map (token) ->
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

onChange = ->
    code = $editor.val()

    # If there is a syntax error this will exit early.
    try
        tokens = CoffeeScript.tokens(code)
    catch e
        return

    showTokens(tokens)

$editor.keyup _.throttle(onChange, 500)

onChange()
