angular.module('AppOne')

# Keep track and add elements to summary for current activity: continually check-point after each answer
# At Activity Finish, flush to disk
# Ability to load some past summary from disk, possibly one just saved, to feed ctrlSummary
.factory("ActivitySummary", ['$q', ($q) ->
    class ActivitySummary
        _key: document.numeric.key.currentActivitySummary
        _read: -> JSON.parse(window.localStorage.getItem(@_key))
        _write: (table) -> window.localStorage.setItem(@_key, JSON.stringify(table))
        _clear: -> window.localStorage.setItem(@_key, JSON.stringify({}))

        _get: (fieldName) -> @_read()[fieldName]
        _add: (fieldName, data) ->
            table = @_read()
            table[fieldName] = data
            @_write(table)
        _remove: (fieldName) ->
            table = @_read()
            if table[fieldName]
                delete table[fieldName]
                @_write(table)

        constructor: ->
            if !@_read()
                @_clear()


    console.log('CALL TO FACTORY: ActivitySummary')
    new ActivitySummary()
])