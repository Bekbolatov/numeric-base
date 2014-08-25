angular.module('AppOne')

# holds Meta info for bookmarked activities - aka "installed activities"
# if no such are available in localStorage[document.numeric.keys.bookmarkedActivities],
# then bootstraps with document.numeric.defaultActivitiesList
# depends on ActivityMeta
.factory("Bookmarks", ['ActivityMeta', (ActivityMeta ) ->
    class Bookmarks
        bookmarks: {} # allows dirty-checking, writes-through to localStorage
        get: (activityId) -> @bookmarks[activityId]

        _key: document.numeric.key.bookmarkedActivities
        _read: -> JSON.parse(window.localStorage.getItem(@_key))
        _write: (table) -> window.localStorage.setItem(@_key, JSON.stringify(table))

        _clear: -> window.localStorage.setItem(@_key, JSON.stringify({}))
        _add: (activityId, metaData) ->
            table = @_read()
            table[activityId] = metaData
            @_write(table)

        _remove: (activityId) ->
            table = @_read()
            if table[activityId]
                delete table[activityId]
                @_write(table)

        clear: () ->
            for id, meta of @bookmarks
                delete @bookmarks[id]
            @_clear()

        add: (activityId, meta) =>
            ActivityMeta.get(activityId)
            .then(
                (data) =>
                    @bookmarks[activityId] = data
                    @_add(activityId, data)
                (status) -> console.log(status)
            )

        remove: (activityId) ->
            if @bookmarks[activityId]
                delete @bookmarks[activityId]
            @_remove(activityId)


        constructor: ->
            if !@_read() # bootstrap with default given in _init.js (if nothing was stored before)
                @_clear()
                for activityId in document.numeric.defaultActivitiesList
                    @add(activityId)
            else # load previously saved
                previous = @_read()
                for id, meta of previous
                    @bookmarks[id] = meta

    console.log('CALL TO FACTORY: Bookmarks')
    new Bookmarks()
])
