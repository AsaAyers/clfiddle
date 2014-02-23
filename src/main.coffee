
# I'm making this global in case people want to poke at it from the console.
window.coffeelint = require '../node_modules/coffeelint/lib/coffeelint.js'
_ = require '../bower_components/lodash/dist/lodash.js'

# This doesn't create a module, so it will create `window.CodeMirror`
require '../bower_components/codemirror/lib/codemirror.js'
require '../bower_components/codemirror/addon/lint/lint.js'
require '../bower_components/codemirror/addon/lint/coffeescript-lint.js'

$('#output-tabs a').click (e) ->
    e.preventDefault()
    $(this).tab('show')


$editor = $('.editor')
$ast = $('#ast')
$tokens = $('#tokens')

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

onChange = ->
    code = $editor.val()

    try
        CoffeeScript.tokens(code)
    catch e
        return

    showTokens(code)
    showAST(code)

onChange = _.throttle(onChange, 500)

$editor = $editor
codeEditor = CodeMirror.fromTextArea $editor.get(0),
    mode: "javascript"
    lineNumbers: true
    gutters: ["CodeMirror-lint-markers"]
    showTrailingSpace: false
    lint: CodeMirror.lint.coffeescript

codeEditor.on 'change', (cm) ->
    cm.save()
    onChange()

onChange()



