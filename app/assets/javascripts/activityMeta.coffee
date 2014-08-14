angular.module('AppOne')

.factory("ActivityMeta", ['$q', '$http' , ($q, $http ) ->

    class ActivityMeta
        _key: 'numericActivitiesMeta'
        _urls:
            metaLocal: document.numeric.urlActivityMetaLocal
            bodyLocal: document.numeric.urlActivityBodyLocal
            metaServer: document.numeric.urlActivityMetaServer
            bodyServer: document.numeric.urlActivityBodyServer
            publicActivitiesList: document.numeric.urlActivityMetaListServer

        _read: ->
            JSON.parse(window.localStorage.getItem(@_key))
        _write: (table) ->
            window.localStorage.setItem(@_key, JSON.stringify(table))
        _add: (activityId, activityInfo) ->
            table = @_read()
            table[activityId] = activityInfo
            @_write(table)
        _remove: (activityId) ->
            table = @_read()
            if table[activityId]
                delete table[activityId]
                @_write(table)
        _get: (activityId) ->
            table = @_read()
            table[activityId]
        _clear: ->
            window.localStorage.setItem(@_key, JSON.stringify({}))
        _init: ->
            table = @_read()
            if !table
                @_clear()

        clearLocalStorage: ->
            @_clear()
        get: (key) ->
            deferred = $q.defer()
            cached = @_get(key)
            if cached
                deferred.resolve(cached)
            else
                $http.get(@_urls.metaLocal + key + '.json')
                .then( \
                    (response, status, headers, config) =>
                        data = response.data
                        data.id = key
                        @_add(key, data)
                        deferred.resolve(data)
                    (data, status, headers, config) =>
                        $http.get(@_urls.metaServer + key + '.json')
                            .then( \
                                (response, status, headers, config) =>
                                    data = response.data
                                    data.id = key
                                    @_add(key, data)
                                    deferred.resolve(data)
                                (data, status, headers, config) =>
                                    deferred.reject(status)
                            )
               )
            deferred.promise

        constructor: ->
            @_init()

    new ActivityMeta()
])