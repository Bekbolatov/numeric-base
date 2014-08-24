angular.module('AppOne')

.factory("FS", ['$q', ($q) ->
    class FS
        constructor: ->
            window.requestFileSystem = window.requestFileSystem || window.webkitRequestFileSystem
            @_getDirEntry(document.numeric.url.base.fs, {create:true})
            .then( => @getDirEntry(document.numeric.path.result, {create:true}))

        _errorHandler: (dfd) ->
            (e) ->
                msg = switch e.code
                    when FileError.QUOTA_EXCEEDED_ERR then 'QUOTA_EXCEEDED_ERR'
                    when FileError.NOT_FOUND_ERR then 'NOT_FOUND_ERR'
                    when FileError.SECURITY_ERR then 'SECURITY_ERR'
                    when FileError.INVALID_MODIFICATION_ERR then 'INVALID_MODIFICATION_ERR'
                    when FileError.INVALID_STATE_ERR then 'INVALID_STATE_ERR'
                    else 'Unknown Error: ' + e.code
                console.log('ERROR: ' + msg)
                dfd.reject(msg)

        _printEntries: (entries) ->
            console.log('entries:')
            for entry in entries
                console.log(entry.name)

#        chromeRequestQuota: ->
#            deferred = $q.defer()
#            navigator.webkitPersistentStorage.requestQuota(
#                1024*1024
#                (bytes) ->
#                    console.log('obtained bytes: ' + bytes)
#                    deferred.resolve(bytes)
#                (status) ->
#                    console.log('could not request quota: ' + status)
#                    deferred.reject(status)
#            )
#            deferred.promise

        getFileSystem: =>
            deferred = $q.defer()
            if (typeof LocalFileSystem != 'undefined')
               window.requestFileSystem(
                LocalFileSystem.PERSISTENT
                0
                (fs) => deferred.resolve(fs)
                @_errorHandler(deferred))
            else
                console.log('LocalFileSystem is undefined')
#                @chromeRequestQuota()
#                .then( (bytes) =>
#                   window.requestFileSystem(
#                    window.PERSISTENT
#                    1024*1024
#                    (fs) => deferred.resolve(fs)
#                    @_errorHandler(deferred))
#                )
            deferred.promise

        # get Files and Dirs from here
        _getDirEntry: (dirName, options) ->
            console.log('getting dirEntry: ' + dirName)
            deferred = $q.defer()
            @getFileSystem()
            .then(
                (fs) =>
                    if dirName == '/'
                        deferred.resolve(fs.root)
                    else
                        fs.root.getDirectory(
                            dirName
                            options
                            (dirEntry) -> deferred.resolve(dirEntry)
                            @_errorHandler(deferred))
            )
            deferred.promise

        _getFileEntry: (fileName, options) ->
            console.log('getting fileEntry: ' + fileName)
            deferred = $q.defer()
            @getFileSystem()
            .then(
                (fs) =>
                    fs.root.getFile(
                        fileName
                        options
                        (fileEntry) -> deferred.resolve(fileEntry)
                        @_errorHandler(deferred))
            )
            deferred.promise

        getDirEntry: (dirName, options) -> @_getDirEntry(document.numeric.url.base.fs + dirName, options)
        getFileEntry: (fileName, options) -> @_getFileEntry(document.numeric.url.base.fs + fileName, options)

        # ls contents
        getContents: (dirName) =>
            deferred = $q.defer()
            @getDirEntry(dirName, {create: false})
            .then(
                (dirEntry) =>
                    console.log(dirEntry)
                    console.log('fullPath:' + dirEntry.fullPath)
                    console.log('toURL:' + dirEntry.toURL())
                    directoryReader = dirEntry.createReader()
                    directoryReader.readEntries(@_printEntries, @_errorHandler))

        # File reader/writer
        getFileWriter: (fileName) ->
            deferred = $q.defer()
            @getFileEntry(fileName, {create: true, exclusive: false})
            .then(
                (fileEntry) => fileEntry.createWriter(
                    (fileWriter) -> deferred.resolve(fileWriter)
                    @_errorHandler(deferred))
            )
            deferred.promise
        getFileReader: (fileName) ->
            deferred = $q.defer()
            @getFileEntry(fileName, {create: false})
            .then( (fileEntry) ->
                fileEntry.file(
                    (file) ->
                        reader = new FileReader()
                        reader.onloadend = (evt) -> deferred.resolve(evt.target.result)
                        reader.readAsText(file)
                    (fail) -> deferred.reject(fail))
            )
            deferred.promise

        # write/read strings to/from file
        writeToFile: (fileName, textData) ->
            deferred = $q.defer()
            @getFileWriter(fileName)
            .then(
                (fileWriter) ->
                    console.log('obtained filewriter for: ' + fileName)
                    fileWriter.seek(0)
                    fileWriter.write(textData)
                    deferred.resolve('wrote to file: ' + fileName)
            )
            deferred.promise

        readFromFile: (fileName) ->
            deferred = $q.defer()
            @getFileReader(fileName)
            .then(
                (data) ->
                    deferred.resolve('retrieved data: ' + data)
            )
            deferred.promise


        writeDataToFile: (fileName, buffer) -> @writeToFile(fileName, JSON.stringify(buffer))
        readDataFromFile: (fileName) -> JSON.parse(@readFromFile(fileName))

    console.log('CALL TO FACTORY: FS')
    new FS()
])