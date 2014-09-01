angular.module('AppOne')

.factory "DeviceId", ['md5', (md5) ->
    class DeviceId
        _chars : 'z123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZAB'
        _randomChar: () -> @_chars[Math.random()*64 | 0]
        _randomString: (n) ->
            s = ''
            for i in [1..n]
                s = s + @_randomChar()
            s

        _key: document.numeric.key.deviceId
        _read: -> JSON.parse(window.localStorage.getItem(@_key))
        _write: (table) -> window.localStorage.setItem(@_key, JSON.stringify(table))
        _clear: -> window.localStorage.setItem(@_key, JSON.stringify({}))

        constructor: -> # maybe also save to disk - unfortunately we are not encrypting anything
            ids = @_read()
            if ids
                @deviceSecretId = ids.private
                @devicePublicId = ids.public
            else
                @deviceSecretId = @_randomString(50)
                @devicePublicId = md5.createHash(@deviceSecretId)
                @_write({ private: @deviceSecretId, public: @devicePublicId })

        qs: -> '?did=' + @devicePublicId
        qsAnd: -> '&did=' + @devicePublicId

        qsWithCb: (ms) ->
            cb = "&cb=" + Math.round( (new Date()) / ms )
            @qs() + cb

        qsAndWithCb: (ms) ->
            cb = "&cb=" + Math.round( (new Date()) / ms )
            @qsAnd() + cb

    console.log('CALL TO FACTORY: DeviceId')
    new DeviceId()
]

