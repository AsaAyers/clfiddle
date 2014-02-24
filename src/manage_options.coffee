_ = require '../bower_components/lodash/dist/lodash.js'

# This is a modified version of
# codemirror/addon/lint/json-lint.js
CodeMirror.registerHelper "lint", "json", (text) ->
    found = []
    jsonlint.parser.parseError = (str, hash) ->
        { loc } = hash
        found.push
            from: CodeMirror.Pos(loc.first_line - 1, loc.first_column),
            to: CodeMirror.Pos(loc.last_line - 1, loc.last_column),
            message: str

    try
        jsonlint.parse(text)

    return found

$options = $('#options')

# CodeMirror's linter doesn't have a mechanism to pass options, so this will
# cause `coffeelint.lint(code)` to default to the user's config.
currentConfig = {}
coffeelint.lint = _.wrap coffeelint.lint, (l, code, config = currentConfig) ->
    l.call this, code, config

do -> # render options
    rules = _.cloneDeep(coffeelint.RULES)

    for name, options of rules
        cfg = _.clone(options)
        delete cfg.name
        delete cfg.level
        delete cfg.message
        delete cfg.description
        options.config = JSON.stringify(cfg, undefined, 2)
        options.config = false if options.config is '{}'

    context =
        rules: rules

    template = require './templates/options.hbs'
    $options.html template(context)

$options.find('select').change ->
    currentConfig[@name] ?= {}
    currentConfig[@name].level = @value

$options.find('textarea').each (idx, el) ->

    tmpEditor = CodeMirror.fromTextArea el,
        mode: {
            name: "javascript"
            json: true
        }
        viewportMargin: Infinity
        lineNumbers: true
        gutters: ["CodeMirror-lint-markers"]
        showTrailingSpace: false
        lint: CodeMirror.lint.json

    window.tmpEditor = tmpEditor
    tmpEditor.on 'change', (cm) ->
        try
            data = JSON.parse cm.getValue()
        catch
            return

        name = cm.getTextArea().name
        currentConfig[name] ?= {}
        _.extend currentConfig[name], data



window.currentConfig = currentConfig


