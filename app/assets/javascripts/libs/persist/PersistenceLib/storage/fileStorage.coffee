angular.module 'ModulePersistence'

.factory 'FileStorageManager', ['$q', 'FS', ($q, FS) ->
    class ModulePersistenceFileStorage
        constructor: () ->
            @filesystem = FS
        readText: (key) ->
            deferred = $q.defer()
            @filesystem.readFromFile(key)
            .then (textData)-> deferred.resolve(textData)
            .catch (t) -> deferred.reject(t)
            deferred.promise

        saveText: (key, textData) ->
            deferred = $q.defer()
            @filesystem.writeToFile(key, textData)
            .then -> deferred.resolve(0)
            .catch (t) -> deferred.reject(t)
            deferred.promise

    new ModulePersistenceFileStorage()
]

