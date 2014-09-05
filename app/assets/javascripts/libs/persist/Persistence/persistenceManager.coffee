angular.module 'ModulePersistence'

.factory 'PersistenceManager', ['$q', 'LocalStorageManager', 'FileStorageManager', ( $q, LocalStorageManager, FileStorageManager ) ->
    class PersistenceManager
        constructor: () ->
            @localStore = LocalStorageManager
            @fileStore = FileStorageManager

        save: (key, object) ->
            deferred = $q.defer()

            @localStore.save(key, object)
            .then ->
                console.log('saved to ' + key)
                deferred.resolve(0)
            .catch (t) ->
                console.log('did not save to ' + key)
                console.log(t)
                deferred.reject(t)

            deferred.promise

        read: (key) ->
            deferred = $q.defer()

            @localStore.read(key)
            .then (obj)->
                console.log('read from ' + key)
                console.log(obj)
                deferred.resolve(0)
            .catch (t) ->
                console.log('did not read')
                console.log(t)
                deferred.reject(t)

            deferred.promise


    new PersistenceManager()
]