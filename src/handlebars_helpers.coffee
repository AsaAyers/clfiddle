Handlebars = require('handlebars/runtime').default

Handlebars.registerHelper 'selected', (actual, expected) ->
    if actual is expected then ' selected' else ''
