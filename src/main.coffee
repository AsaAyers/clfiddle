
# I'm making this global in case people want to poke at it from the console.
window.CoffeeLint = require '../node_modules/coffeelint/lib/coffeelint.js'
_ = require '../bower_components/lodash/dist/lodash.js'

$('#output-tabs a').click (e) ->
    e.preventDefault()
    $(this).tab('show')


$editor = $('.editor')
$ast = $('#ast')
$tokens = $('#tokens')
$results = $('#coffeelint-results')

importFromGist = (id, filename = undefined) ->
    $.get("https://api.github.com/gists/#{id}")
    .then (data) ->
        return data.files[filename].content if data.files[filename]

        for name, f of data.files when f.language is 'CoffeeScript'
            return f.content

    .then (content) ->
        $editor.val content
        onChange()

showTokens = (code) ->
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

showAST = (code) ->
    node = CoffeeScript.nodes(code)

    $ast.html $('<pre>').text(JSON.stringify(node, undefined, 2))

showLinter = (code) ->
    context = {}
    try
        context.errors = CoffeeLint.lint(code)
    catch e
        context.error = e

    if context.errors.length is 0 and not context.error?
        context.clean = true

    template = require './templates/report.hbs'

    console.log context
    $results.html template(context)

    if context.errors[0]?.rule is 'coffeescript_error'
        return false

    return not context.error?

onChange = ->
    code = $editor.val()

    if showLinter(code)
        showTokens(code)
        showAST(code)

$editor.keyup _.throttle(onChange, 500)

onChange()
