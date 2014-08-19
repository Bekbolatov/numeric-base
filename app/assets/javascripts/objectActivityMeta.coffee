angular.module('AppOne')

# This only retrieves, and caches, ActivityMeta info - depends only on $q and $http and nothing else
# Main way of using this will be: ActivityMeta.get('com.sparkydots.groupa.activityA') which returns Meta info for this task
# occasionally, for debugging maybe, we can use: ActivityMeta.clearLocalStorage()
.factory("ActivityMeta", ['$q', '$http' , ($q, $http ) ->
    class ActivityMeta
        _key: document.numeric.keys.activitiesMeta
        _urls:
            local: document.numeric.urlActivityMetaLocal
            remote: document.numeric.urlActivityMetaServer
        _read: -> JSON.parse(window.localStorage.getItem(@_key))
        _write: (table) -> window.localStorage.setItem(@_key, JSON.stringify(table))
        _clear: -> window.localStorage.setItem(@_key, JSON.stringify({}))
        _get: (activityId) -> @_read()[activityId]
        _add: (activityId, activityInfo) ->
            table = @_read()
            table[activityId] = activityInfo
            @_write(table)
        _remove: (activityId) ->
            table = @_read()
            if table[activityId]
                delete table[activityId]
                @_write(table)
        _cacheGet: (key) =>
            deferred = $q.defer()
            console.log('|- trying localStorage...')
            cached = @_get(key)
            if cached
                console.log('| |- found in localStorage.')
                deferred.resolve(cached)
            else
                console.log('| |- not found in localStorage.')
                deferred.reject()
            deferred.promise
        _httpGet: (url, key) =>
            =>
                deferred = $q.defer()
                console.log('|- trying ' + url + ' ...')
                $http.get(url, { cache: false })
                .then( \
                    (response) =>
                        console.log('| |- found at ' + url)
                        data = response.data
                        data.id = key
                        @_add(key, data)
                        deferred.resolve(data)
                    (status) =>
                        console.log('| |- not found at ' + url)
                        deferred.reject(status)
                )
                deferred.promise

        constructor: ->
            if !@_read()
                @_clear()

        clearLocalStorage: -> @_clear()

        get: (key) -> # tries localStorage, then localWWW, then remote server
            console.log('Looking for activity ' + key)
            @_cacheGet(key)
            .catch(@_httpGet(@_urls.local + key + '.json', key))
            .catch(@_httpGet(@_urls.remote + key + '.json', key))

    console.log('CALL TO FACTORY: ActivityMeta')
    new ActivityMeta()
])