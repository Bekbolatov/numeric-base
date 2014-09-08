angular.module 'ModuleIdentity'

.factory 'DeviceId', ['md5', 'PersistenceManager', 'RandomFunctions', (md5, PersistenceManager, RandomFunctions ) ->
    class DeviceId
        constructor: -> # maybe also save to disk - unfortunately we are not encrypting anything
            @persister = PersistenceManager.localStoreBlockingPersister(document.numeric.key.deviceId)
            ids = @persister.read()
            if ids
                @deviceSecretId = ids.private
                @devicePublicId = ids.public
            else
                @deviceSecretId = RandomFunctions.randomSomeString(50)
                @devicePublicId = md5.createHash(@deviceSecretId)
                @persister.save({ private: @deviceSecretId, public: @devicePublicId })


        qs: -> '?did=' + @devicePublicId
        qsAnd: -> '&did=' + @devicePublicId

        qsWithCb: (ms) ->
            cb = "&cb=" + Math.round( (new Date()) / ms )
            @qs() + cb

        qsAndWithCb: (ms) ->
            cb = "&cb=" + Math.round( (new Date()) / ms )
            @qsAnd() + cb

    new DeviceId()
]

