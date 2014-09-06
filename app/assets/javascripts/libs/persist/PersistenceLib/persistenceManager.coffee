angular.module 'ModulePersistence'
#
# [-1] - not available
# [0] - empty value, no value stored at key
# [1, t] - some error propagated
.factory 'PersistenceManager', ['$q', 'SerializationMethods', 'LocalStorageManager', 'FileStorageManager', ( $q, SerializationMethods, LocalStorageManager, FileStorageManager ) ->
    class KeyedObjectPersister
        constructor: (@persistenceManager, @key) ->
        read: -> @persistenceManager.read(@key)
        save: (table) -> @persistenceManager.save(@key, table)
        clear: -> @persistenceManager.save(@key, {})

    class KeyedDictionaryWriteThruCache
        constructor: (@persistenceManager, @objkey) ->
            @persister = new KeyedObjectPersister(@persistenceManager, @objkey)
            @cache = {}
        _add: (key, val) =>
            @persister.read()
            .then (table) =>
                table[key] = val
                @persister.save(table)
        _remove: (key) =>
            @persister.read()
            .then (table) =>
                if table[key]
                    delete table[key]
                    @persister.save(table)
        _clear: -> @persister.clear()

        initCacheFromPersisted: ->
            deferred = $q.defer()
            @persister.read()
            .then (saved) =>
                for key, val of saved
                    @cache[key] = val
                deferred.resolve(0)
            .catch (t) =>
                @_clear()
                deferred.reject(0)
            deferred.promise

        get: (key) -> @cache[key]
        add: (key, val) ->
            @cache[key] = val
            @_add(key, val)
        remove: (key) ->
            if @cache[key]
                delete @cache[key]
            @_remove(key)
        clear: () ->
            for key, val of @cache
                delete @cache[key]
            @_clear()

    class PersistenceManager
        constructor: () ->
            @localStore = LocalStorageManager
            @fileStore = FileStorageManager

        serialize: (object) -> SerializationMethods.serialize(object)
        deserialize: (textData) -> SerializationMethods.deserialize(textData)

        #### level 0 ##################
        saveText: (key, textData) ->
            deferred = $q.defer()
            @localStore.saveText(key, textData)
            .then -> deferred.resolve(0)
            .catch (t) ->
                deferred.reject(t)
            deferred.promise

        readText: (key) ->
            deferred = $q.defer()
            @localStore.readText(key)
            .then (textData)-> deferred.resolve(textData)
            .catch (t) ->
                deferred.reject(t)
            deferred.promise

        #### level 1 ##################
        saveObject: (key, object) ->
            deferred = $q.defer()
            try
                textData = @serialize(object)
            catch t
                deferred.reject([1, t])
                return deferred.promise
            @saveText(key, textData)
            .then -> deferred.resolve(0)
            .catch (t) ->
                deferred.reject(t)
            deferred.promise

        readObject: (key) ->
            deferred = $q.defer()
            @readText(key)
            .then (textData) =>
                try
                    obj = @deserialize(textData)
                    deferred.resolve(obj)
                catch t
                    deferred.reject([1, t])
                    return deferred.promise
                deferred.resolve(obj)
            .catch (t) ->
                deferred.reject(t)
            deferred.promise

        ####  Alias save/read - defaults to 'object' argument ####
        save: (key, object) -> @saveObject(key, object)
        read: (key) -> @readObject(key)
        #### level 2  ##################
        keyedObjectPersister: (key) ->
            new KeyedObjectPersister(@, key)
        writeThruCache: (key) ->
            new KeyedDictionaryWriteThruCache(@, key)

    new PersistenceManager()
]