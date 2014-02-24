
# I'm making this global in case people want to poke at it from the console.
window.coffeelint = require '../node_modules/coffeelint/lib/coffeelint.js'
_ = require '../bower_components/lodash/dist/lodash.js'

# This doesn't create a module, so it will create `window.CodeMirror`
require '../bower_components/codemirror/lib/codemirror.js'

require '../bower_components/codemirror/addon/lint/lint.js'
require '../bower_components/codemirror/addon/lint/coffeescript-lint.js'

require './handlebars_helpers.coffee'
showTokens = require './show_tokens.coffee'
require './manage_options.coffee'

$('.nav-tabs a').click (e) ->
    e.preventDefault()
    $(this).tab('show')

$editor = $('.editor')

importFromGist = (id, filename = undefined) ->
    $.get("https://api.github.com/gists/#{id}")
    .then (data) ->
        return data.files[filename].content if data.files[filename]

        for name, f of data.files when f.language is 'CoffeeScript'
            return f.content

    .then (content) ->
        $editor.val content
        onChange()


$ast = $('#ast')
showAST = (code) ->
    try
        node = CoffeeScript.nodes(code)
    catch
        return

    $ast.html $('<pre>').text(JSON.stringify(node, undefined, 2))

onChange = ->
    code = $editor.val()

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

$('a[href="#coffeelint"]').on 'show.bs.tab', ->
    # Force the editor to update and re-lint the file
    codeEditor.setValue codeEditor.getValue()

window.codeEditor = codeEditor

onChange()

