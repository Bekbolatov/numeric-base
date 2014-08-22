angular.module('AppOne')

.factory("FileDownload", ['$q', ($q) ->
    class FileDownload
        download: (uri, fileURL) ->
            console.log('downloading from: ' + uri + ' to: ' + fileURL)
            deferred = $q.defer()
            fileTransfer = new FileTransfer();
            fileTransfer.download(
                uri
                fileURL
                (entry) -> deferred.resolve('ok')
                (error) -> deferred.reject(error.code)
                false
                {
                    headers:
                        "Authorization": "Basic dGVzdHVzZXJuYW1lOnRlc3RwYXNzd29yZA=="
                })
            deferred.promise

    console.log('CALL TO FACTORY: FileDownload')
    new FileDownload()
])