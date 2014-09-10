angular.module 'BaseLib'

.factory "HyperTextManager", [ ->
    class HyperTextManager
        table: (rows, headers) ->
            o = '<table class="problem-generated-table">'
            if headers != undefined
                o += '<tr>'
                for header in headers
                    o += '<th>' + header + '</th>'
                o += '</tr>'
            for row in rows
                o += '<tr>'
                for item in row
                    o += '<td>' + item + '</td>'
                o += '</tr>'
            o + '</table>'
        tableWrapped: (rows, headers) ->
            table = @table(rows, headers)
            "<span class='problem-generated-table-holder'>#{table}</span>"
        fraction: (a, b) ->
            o = '<span class="fraction">'
            o += '<span class="fraction-top">' + a + '</span>'
            o += '<span class="fraction-bottom">' + b + '</span>'
            o + '</span>'
        graphic: (imgdata) ->
            o = '<span class="span-question-graphic">'
            o += '<img class="img-question-graphic" alt="img" src="' + imgdata + '">'
            o + '</span>'

    hyperTextManager = new HyperTextManager()
    document.numeric.modules.HyperText = hyperTextManager
    hyperTextManager
]
