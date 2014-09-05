angular.module 'ModulePersistence'

# LocalStorage
# Also known as web storage, simple storage, or by its alternate session storage interface.
# this API provides synchronous key/value pair storage, and is available in underlying WebView implementations.
# Refer to the W3C spec for details: http://www.w3.org/TR/webstorage/
.factory 'LocalStorageManager', ['$q',($q) ->

    class DefaultRawLocalStorage
        isAvailable: -> window.localStorage != undefined
        getItem: (key) -> window.localStorage.getItem(key)
        setItem: (key, val) -> window.localStorage.setItem(key, val)
        clear: -> window.localStorage.clear()

    class ModuleLocalStorage
        constructor: (@rawStore) -> # e.g. @rawStore = new ModuleRawLocalStorage(new DefaultLocalStorage())
            @deserialize = JSON.parse
            @serialize = JSON.stringify
        clear: -> @rawStore.clear()
        read: (key)->
            deferred = $q.defer()
            if @rawStore.isAvailable()
                try
                    val = @rawStore.getItem(key)
                    if val == undefined
                        deferred.reject([0]) # reject [0]: everything worked ok, but value is undefined - will be useful to know when undefined and also show as rejected
                    else
                        obj = @deserialize(val)
                        deferred.resolve(obj)
                catch t
                    deferred.reject([1, t])
            else
                deferred.reject([-1]) # reject [-1]: service is not available on this system
            deferred.promise
        save: (key, obj) ->
            deferred = $q.defer()
            if @rawStore.isAvailable()
                try
                    val = @serialize(obj)
                    @rawStore.setItem(key, val)
                    deferred.resolve(0)
                catch t
                    deferred.reject([1, t])
            else
                deferred.reject([-1])
            deferred.promise

    new ModuleLocalStorage(new DefaultRawLocalStorage())
]