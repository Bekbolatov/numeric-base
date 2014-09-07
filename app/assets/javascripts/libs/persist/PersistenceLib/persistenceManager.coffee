angular.module 'ModulePersistence'
#
# [-1] - not available
# [0] - empty value, no value stored at key
# [1, t] - some error propagated
.factory 'PersistenceManager', ['$q', 'SerializationMethods', 'LocalStorageManager', 'FileStorageManager', 'ServerStorageManager', ( $q, SerializationMethods, LocalStorageManager, FileStorageManager, ServerStorageManager ) ->
    class Persister
        constructor: (@persistenceManager, @store, @key) ->
        read: -> @persistenceManager.readObject(@store, @key)
        save: (table) -> @persistenceManager.saveObject(@store, @key, table)
        clear: -> @persistenceManager.saveObject(@store, @key, {})
    class DictionaryPersister
        constructor: (@persistenceManager, @store, @objkey) ->
            @persister = new Persister(@persistenceManager, @store, @objkey)
        init: () ->
            deferred = $q.defer()
            @persister.read()
            .then (val) -> deferred.resolve(val)
            .catch (t) =>
                @persister.clear()
                .then ->
                    deferred.reject(t)
            deferred.promise
        get: (key) =>
            deferred = $q.defer()
            @persister.read()
            .then (table) => deferred.resolve(table[key])
            .catch (t) => deferred.reject(t)
            deferred.promise
        set: (key, val) =>
            deferred = $q.defer()
            @persister.read()
            .then (table) =>
                table[key] = val
                @persister.save(table)
                .then (result) -> deferred.resolve(result)
                .catch (result) -> deferred.reject(result)
            .catch (result) -> deferred.reject(result)
            deferred.promise
        remove: (key) =>
            @persister.read()
            .then (table) =>
                if table[key]
                    delete table[key]
                    @persister.save(table)
        clear: -> @persister.clear()

    class DictionaryCacheWriteThruToPersister
        constructor: (@persistenceManager, @store, @objkey) ->
            @cache = {}
            @persister = new DictionaryPersister(@persistenceManager, @store, @objkey)
        init: ->
            deferred = $q.defer()
            @persister.init()
            .then (saved) =>
                for key, val of saved
                    @cache[key] = val
                deferred.resolve(saved)
            .catch (t) -> deferred.reject(t)
            deferred.promise

        get: (key) -> @cache[key]
        set: (key, val) ->
            @cache[key] = val
            @persister.set(key, val)
        remove: (key) ->
            if @cache[key]
                delete @cache[key]
            @persister.remove(key)
        clear: () ->
            for key, val of @cache
                delete @cache[key]
            @persister.clear()

    class PersistenceManager
        constructor: () ->
            @localStore = LocalStorageManager
            @fileStore = FileStorageManager
            @serverStore = ServerStorageManager

        serialize: (object) -> SerializationMethods.serialize(object)
        deserialize: (textData) -> SerializationMethods.deserialize(textData)

        saveText: (store, key, textData) -> store.saveText(key, textData)
        readText: (store, key) -> store.readText(key)

        saveObject: (store, key, object) ->
            deferred = $q.defer()
            try
                textData = @serialize(object)
            catch t
                deferred.reject([1, t])
                return deferred.promise
            @saveText(store, key, textData)
            .then (result) -> deferred.resolve(result)
            .catch (t) -> deferred.reject(t)
            deferred.promise
        readObject: (store, key) ->
            deferred = $q.defer()
            @readText(store, key)
            .then (textData) =>
                try
                    obj = @deserialize(textData)
                    deferred.resolve(obj)
                catch t
                    deferred.reject([1, t])
                    return deferred.promise
                deferred.resolve(obj)
            .catch (t) -> deferred.reject(t)
            deferred.promise

        ####  Alias save/read - defaults to 'object' argument ####
        save: (key, object) -> @saveObject(@localStore, key, object)
        read: (key) -> @readObject(@localStore, key)
        #### level 4  ##################
        localStorePersister: (key) -> new Persister(@, @localStore, key)
        cacheWithwriteThruToLocalStorePersister: (key) -> new DictionaryCacheWriteThruToPersister(@, @localStore, key)

    new PersistenceManager()
]