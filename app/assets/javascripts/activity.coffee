angular.module('AppOne')

.factory("Activity", ['$q', '$http' , ($q, $http ) ->
    class Downloader
        constructor: ->
            window.requestFileSystem  = window.requestFileSystem || window.webkitRequestFileSystem;
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
        onInitFs: (uri, fileURL, dfd) ->
            (fs) ->
                fileTransfer = new FileTransfer();
                fileTransfer.download(
                    uri
                    fileURL
                    (entry) ->
                        console.log("download complete: " + entry.fullPath)
                        dfd.resolve('ok')
                    (error) ->
                        console.log("download error source " + error.source)
                        console.log("download error target " + error.target)
                        console.log("upload error code" + error.code)
                        dfd.reject(error.code)
                    false
                    {
                        headers:
                            "Authorization": "Basic dGVzdHVzZXJuYW1lOnRlc3RwYXNzd29yZA=="

                    }
            )
        download: (uri, fileURL) ->
            console.log('accessing persistent storage ' + window.requestFileSystem)
            deferred = $q.defer()
            window.requestFileSystem(LocalFileSystem.PERSISTENT, 0, @onInitFs(uri, fileURL, deferred), @errorHandler)
            deferred.promise

    class Activity
        _directoryBody:  document.numeric.directoryActivityBody
        _urls:
            local: document.numeric.urlActivityLocal
            remote: document.numeric.urlActivityServer
        _downloader: new Downloader()
        _copy: (uri, file) ->
            @_downloader.download(uri, file)
        _downloadActivityFromLocal: (key) -> @_downloader.download(@_urls.local + key, @_directoryBody + file)
        _downloadActivityFromRemote: (key) -> @_downloader.download(@_urls.remote + key, @_directoryBody + file)


    new Activity()
])