angular.module('AppOne')

.factory("FileDownload", ['$q', 'DeviceId', ($q, DeviceId ) ->
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
                        "Authorization": "Basic " + DeviceId.deviceSecretId
                })
            deferred.promise

    console.log('CALL TO FACTORY: FileDownload')
    new FileDownload()
])