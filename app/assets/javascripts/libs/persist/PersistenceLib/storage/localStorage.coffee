angular.module 'ModulePersistence'

.factory 'LocalStorageManager', ['$q',($q) ->

    class DefaultRawLocalStorage
        isAvailable: -> window.localStorage != undefined
        getItem: (key) -> window.localStorage.getItem(key)
        setItem: (key, val) -> window.localStorage.setItem(key, val)
        clear: -> window.localStorage.clear()

    class ModuleLocalStorage
        constructor: (@rawStore) ->
        clear: -> @rawStore.clear()

        readText: (key) ->
            deferred = $q.defer()
            if @rawStore.isAvailable()
                try
                    textData = @rawStore.getItem(key)
                    if textData == null || textData == undefined
                        deferred.reject([0])
                    else
                        deferred.resolve(textData)
                catch t
                    deferred.reject([1, t])
            else
                deferred.reject([-1])
            deferred.promise

        saveText: (key, textData) ->
            deferred = $q.defer()
            if @rawStore.isAvailable()
                try
                    @rawStore.setItem(key, textData)
                    deferred.resolve(0)
                catch t
                    deferred.reject([1, t])
            else
                deferred.reject([-1])
            deferred.promise

    new ModuleLocalStorage(new DefaultRawLocalStorage())
]