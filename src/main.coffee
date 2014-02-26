###
# global $ CoffeeScript CodeMirror
###

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

nodeCache = []
BaseNode = undefined

# The Base class for nodes is not exposed by CoffeeScript, but it can be
# extracted this way so I can monkey patch it.
do ->
    node = CoffeeScript.nodes("'string'")
    # I'm fairly sure this is a block instance and not Block, as
    # block.constructorname is "Block"
    block = Object.getPrototypeOf node
    BaseNode = Object.getPrototypeOf(block).constructor
    BaseNode::_origToString = BaseNode::toString

    BaseNode::toString = (idt = '', name = @constructor.name) ->
        id = nodeCache.length
        name = "<span id='#{id}' data-title='#{name}'>#{name}</span>"
        nodeCache.push this

        @_origToString idt, name

    Literal = node.expressions[0].base.constructor

    Literal::_origToString = Literal::toString

    Literal::toString = ->
        id = nodeCache.length
        string = @_origToString()
        string = "<span id='#{id}' data-title='#{name}'>#{string}</span>"
        nodeCache.push this
        string

showAST = (code) ->
    try
        node = CoffeeScript.nodes(code)
    catch
        return

    nodeCache.length = 0
    $('#ast-tree').html(node.toString())
    $('#ast-tree').find('span').popover
        trigger: 'click'
        html: true
        placement: 'auto'
        content: ->
            id = parseInt(@id, 10)
            node = nodeCache[id]
            tmp = {}
            for key, value of node
                tmp[key] = value
                if key in node.children
                    if _.isArray value
                        tmp[key] = value.map (v) ->
                            '&'+v.constructor.name
                    if value instanceof BaseNode
                        tmp[key] = '&'+value.constructor.name
                else
                    tmp[key] = value

            filter = (key, value) ->
                return if value instanceof BaseNode
                value

            "<pre>#{JSON.stringify tmp, filter, 2}</pre>"


onChange = ->
    code = $editor.val()

    showTokens(code)
    showAST(code)

onChange = _.throttle(onChange, 500)

$editor = $editor
$ts = $("#lint-timestamp")
codeEditor = CodeMirror.fromTextArea $editor.get(0),
    mode: "javascript"
    lineNumbers: true
    gutters: ["CodeMirror-lint-markers"]
    showTrailingSpace: false
    lint:
        getAnnotations: CodeMirror.lint.coffeescript
        onUpdateLinting: (annotationsNotSorted, annotations) ->
            if Object.keys(annotations).length is 0
                state = 'Your code is lint free!'
            else
                state = 'Your code has lint.'

            # I found my self asking "Did it work?" when I pasted code in and
            # it found nothing. The timestamp should help with verifying that
            # it's actually running.
            $ts.text "#{new Date()}: #{state}"

codeEditor.on 'change', (cm) ->
    cm.save()
    onChange()

$('a[href="#coffeelint"]').on 'show.bs.tab', ->
    # Force the editor to update and re-lint the file
    codeEditor.setValue codeEditor.getValue()

window.codeEditor = codeEditor

onChange()

