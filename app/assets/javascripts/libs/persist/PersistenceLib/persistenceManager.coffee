angular.module 'ModulePersistence'

.factory 'PersistenceManager', ['$q', 'SerializationMethods', 'LocalStorageManager', 'FileStorageManager', 'ServerStorageManager', ( $q, SerializationMethods, LocalStorageManager, FileStorageManager, ServerStorageManager ) ->
    class PersistenceManager
        constructor: () ->
            @localStore = LocalStorageManager
            @fileStore = FileStorageManager
            @serverStore = ServerStorageManager

        serialize: (object) -> SerializationMethods.serialize(object)
        deserialize: (textData) -> SerializationMethods.deserialize(textData)

        saveText: (store, key, textData) -> store.saveText(key, textData)
        readText: (store, key) -> store.readText(key)

        saveTextBlocking: (store, key, textData) -> store.saveTextBlocking(key, textData)
        readTextBlocking: (store, key) -> store.readTextBlocking(key)

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

        saveObjectBlocking: (store, key, object) ->
            try
                textData = @serialize(object)
            catch t
                return null
            return @saveTextBlocking(store, key, textData)
        readObjectBlocking: (store, key) ->
            try
                textData = @readTextBlocking(store, key)
                obj = @deserialize(textData)
                return obj
            catch t
                return null

        ####  Alias save/read - defaults to 'object' argument ####
        save: (key, object) -> @saveObject(@localStore, key, object)
        read: (key) -> @readObject(@localStore, key)
        #### level 4  ##################
        localStorePersister: (key) -> new StorePersister(@, @localStore, key)
        localStoreBlockingPersister: (key) -> new StoreBlockingPersister(@, @localStore, key)
        localStoreDictionaryPersister: (key) -> new DictionaryStorePersister(@, @localStore, key)
        localStoreBlockingDictionaryPersister: (key) -> new DictionaryStoreBlockingPersister(@, @localStore, key)
        cacheWithwriteThruToLocalStorePersister: (key) -> new DictionaryCacheWriteThruStorePersister(@, @localStore, key)


    class StorePersister
        constructor: (@persistenceManager, @store, @key) ->
        read: -> @persistenceManager.readObject(@store, @key)
        save: (table) -> @persistenceManager.saveObject(@store, @key, table)
        clear: -> @persistenceManager.saveObject(@store, @key, {})

    class StoreBlockingPersister
        constructor: (@persistenceManager, @store, @key) ->
        read: -> @persistenceManager.readObjectBlocking(@store, @key)
        save: (table) -> @persistenceManager.saveObjectBlocking(@store, @key, table)
        clear: -> @persistenceManager.saveObjectBlocking(@store, @key, {})


    class DictionaryStorePersister
        constructor: (@persistenceManager, @store, @objkey) ->
            @persister = new StorePersister(@persistenceManager, @store, @objkey)
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


    class DictionaryStoreBlockingPersister
        constructor: (@persistenceManager, @store, @objkey) ->
            @persister = new StoreBlockingPersister(@persistenceManager, @store, @objkey)
        init: () ->
            val = @persister.read()
            if val != undefined && val != null
                return val
            else
                @persister.clear()
                return null
        getAll: (key) =>
            @persister.read()
        get: (key) =>
            table = @persister.read()
            return table[key]
        set: (key, val) =>
            table = @persister.read()
            table[key] = val
            @persister.save(table)
        remove: (key) =>
            table = @persister.read()
            if table[key]
                delete table[key]
                @persister.save(table)
        clear: -> @persister.clear()

    class DictionaryCacheWriteThruStorePersister
        constructor: (@persistenceManager, @store, @objkey) ->
            @cache = {}
            @persister = new DictionaryStorePersister(@persistenceManager, @store, @objkey)
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

    new PersistenceManager()
]