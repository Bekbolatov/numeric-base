angular.module('AppOne')

.factory("ActivityMeta", ['$q', '$http', 'Settings', 'ServerHttp', 'PersistenceManager', ($q, $http, Settings, ServerHttp, PersistenceManager ) ->
    class ActivityMeta
        _key: document.numeric.key.activitiesMeta
        _urls:
            local: -> document.numeric.url.base.local + document.numeric.path.meta
            remote: -> Settings.get('mainServerAddress') + document.numeric.path.meta
        _uriLocal: (activityId) -> @_urls.local() + activityId
        _uriRemote: (activityId) -> @_urls.remote() + activityId

        _cacheGet: (key) =>
            deferred = $q.defer()
            cached = @writeThruCache.get(key)
            if cached
                deferred.resolve(cached)
            else
                deferred.reject()
            deferred.promise
        _httpGet: (url, key) =>
            =>
                deferred = $q.defer()
                ServerHttp.get(url)
                .then(
                    (response) =>
                        data = response.data
                        data.id = key
                        @writeThruCache.set(key, data)
                        deferred.resolve(data)
                    (status) =>
                        deferred.reject(status)
                )
                deferred.promise

        get: (key) ->
            @_cacheGet(key)
            .catch(@_httpGet( @_uriLocal(key), key))
            .catch(@_httpGet( @_uriRemote(key), key))
        set: (key, meta) -> @writeThruCache.set(key, meta)

        constructor: ->
            @writeThruCache = PersistenceManager.cacheWithwriteThruToLocalStorePersister(document.numeric.key.bookmarkedActivities)
            @writeThruCache.init()

    new ActivityMeta()
])