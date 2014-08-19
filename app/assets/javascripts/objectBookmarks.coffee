angular.module('AppOne')

# holds Meta info for bookmarked activities - aka "installed activities"
# if no such are available in localStorage[document.numeric.keys.bookmarkedActivities],
# then bootstraps with document.numeric.defaultActivitiesList
# depends on ActivityMeta
.factory("Bookmarks", ['ActivityMeta', (ActivityMeta ) ->
    class Bookmarks
        _key: document.numeric.keys.bookmarkedActivities
        _read: -> JSON.parse(window.localStorage.getItem(@_key))
        _write: (table) -> window.localStorage.setItem(@_key, JSON.stringify(table))
        _clear: -> window.localStorage.setItem(@_key, JSON.stringify({}))
        _get: (activityId) -> @_read()[activityId]
        _add: (activityId, metaData) ->
            table = @_read()
            table[activityId] = metaData
            @_write(table)
        _remove: (activityId) ->
            table = @_read()
            if table[activityId]
                delete table[activityId]
                @_write(table)

        add: (activityId) =>
            ActivityMeta.get(activityId)
            .then(
                (data) => @_add(activityId, data)
                (status) -> console.log(status)
            )
        remove: (activityId) -> @_remove(activityId)
        get: (activityId) -> @_get(activityId)
        getAll: (activityId) -> @_read()

        constructor: ->
            if !@_read() # bootstrap is nothing was stored before
                @_clear()
                for activityId in document.numeric.defaultActivitiesList
                    @add(activityId)

    console.log('CALL TO FACTORY: Bookmarks')
    new Bookmarks()
])
