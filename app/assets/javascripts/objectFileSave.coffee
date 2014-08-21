angular.module('AppOne')

.factory("FileSave", ['$q', ($q ) ->
    class FileSave
        constructor: ->
            if window.requestFileSystem
                @webkit = false
            else
                window.requestFileSystem = window.webkitRequestFileSystem
                @webkit = true
            console.log('FileSave: requestFileSystem webkit: ' + @webkit)
        errorHandler = (dfd) ->
            (e) ->
                msg = switch e.code
                    when FileError.QUOTA_EXCEEDED_ERR then 'QUOTA_EXCEEDED_ERR'
                    when FileError.NOT_FOUND_ERR then 'NOT_FOUND_ERR'
                    when FileError.SECURITY_ERR then 'SECURITY_ERR'
                    when FileError.INVALID_MODIFICATION_ERR then 'INVALID_MODIFICATION_ERR'
                    when FileError.INVALID_STATE_ERR then 'INVALID_STATE_ERR'
                    else 'Unknown Error'
                console.log('ERROR: ' + msg)
                dfd.reject(msg)
        saveOnInitFs: (fileName, buffer, dfd) ->
            (fs) ->
                fileTransfer = new FileTransfer();
                fileTransfer.download(
                    uri
                    fileURL
                    (entry) -> dfd.resolve('ok')
                    (error) -> dfd.reject(error.code)
                    false
                    {
                        headers:
                            "Authorization": "Basic dGVzdHVzZXJuYW1lOnRlc3RwYXNzd29yZA=="
                    }
            )
        download: (fileName, buffer) ->
            deferred = $q.defer()
            if (typeof LocalFileSystem != 'undefined')
               window.requestFileSystem(LocalFileSystem.PERSISTENT, 0, @saveOnInitFs(fileName, buffer, deferred), @errorHandler)
            else
               window.requestFileSystem(window.PERSISTENT, 0, @saveOnInitFs(fileName, buffer, deferred), @errorHandler)
            deferred.promise

    console.log('CALL TO FACTORY: FileSave')
    new FileSave()
])