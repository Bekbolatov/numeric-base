angular.module('AppOne')

.factory("Settings", [  ->
    class Settings
        _key: document.numeric.key.settings
        _read: -> JSON.parse(window.localStorage.getItem(@_key))
        _write: (table) -> window.localStorage.setItem(@_key, JSON.stringify(table))
        _clear: -> window.localStorage.setItem(@_key, JSON.stringify({}))

        _get: (attr) -> @_read()[attr]
        _add: (attr, data) ->
            table = @_read()
            table[attr] = data
            @_write(table)
        _remove: (attr) ->
            table = @_read()
            if table[attr] != undefined
                delete table[attr]
                @_write(table)
        defaults:
            historyPageSize: 10
            historyServerSync: false
            mainServerAddress: document.numeric.url.base.server

        getDefault: (attr) -> @defaults[attr]
        get: (attr) ->
            storedValue = @_get(attr)
            if storedValue != undefined
                return storedValue
            else
                return @defaults[attr]
        set: (attr, newValue) -> @_add(attr, newValue)
        unset: (attr) -> @_remove(attr)

        constructor: ->
            if !@_read()
                @_write({})

    console.log('CALL TO FACTORY: Settings')
    new Settings()
])