angular.module('AppOne')

.factory("ActivityMeta", ['$q', '$http' , ($q, $http ) ->
    class ActivityMeta
        _key: 'numericActivitiesMeta'
        _urls:
            local: document.numeric.urlActivityMetaLocal
            remote: document.numeric.urlActivityMetaServer
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

        _httpGet: (url, key) =>
            =>
                deferred = $q.defer()
                console.log('trying ' + url + ' ...')
                $http.get(url)
                .then( \
                    (response) =>
                        data = response.data
                        data.id = key
                        @_add(key, data)
                        deferred.resolve(data)
                    (status) =>
                        deferred.reject(status)
                )
                deferred.promise

        clearLocalStorage: ->
            @_clear()

        newget: (key) ->
            deferred = $q.defer()
            cached = @_get(key)
            if cached
                deferred.resolve(cached)
                return deferred.promise

            @_httpGet(@_urls.local + key + '.json', key)()
            .catch(@_httpGet(@_urls.remote + key + '.json', key))
            .catch(@_httpGet(@_urls.remote + key + '.json', key))


        get: (key) ->
            deferred = $q.defer()
            cached = @_get(key)
            if cached
                deferred.resolve(cached)
            else
                $http.get(@_urls.local + key + '.json')
                .then(\
                    (response, status, headers, config) =>
                        data = response.data
                        data.id = key
                        @_add(key, data)
                        deferred.resolve(data)
                    (data, status, headers, config) =>
                        $http.get(@_urls.remote + key + '.json')
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