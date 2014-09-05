angular.module 'ModulePersistence'

.factory 'ServerHttp', ['$q', ($q) ->
    class ModulePersistenceFileStorage
        constructor: () ->
            console.log('s')

    new ModulePersistenceFileStorage()
]