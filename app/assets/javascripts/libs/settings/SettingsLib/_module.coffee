angular.module 'ModuleSettings', ['ModulePersistence']

angular.module 'ModuleSettings'
.factory("Settings", ['$q', 'PersistenceManager', ( $q, PersistenceManager )  ->
    class Settings
        init: (@key, @defaults) ->
            deferred = $q.defer()
            @writeThruCache = PersistenceManager.cacheWithwriteThruToLocalStorePersister(@key)
            @writeThruCache.init()
            .then (t) =>
                @ready = true
                deferred.resolve(t)
            .catch (t) =>
                if t[0] == 0
                    @ready = true
                    deferred.resolve(0)
                else
                    deferred.reject(t)
            deferred.promise
        getDefault: (attr) -> @defaults[attr]
        get: (attr) ->
            storedValue = @writeThruCache.get(attr)
            if storedValue != undefined
                return storedValue
            else
                return @defaults[attr]
        set: (attr, newValue) -> @writeThruCache.set(attr, newValue)
        unset: (attr) -> @writeThruCache.remove(attr)

    new Settings()
])