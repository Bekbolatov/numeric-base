angular.module('ModulePersistence')

.factory("FS", ['$q', 'md5', ($q, md5) ->
    class FS
        constructor: ->
            @quota = 10
            @salt = 'only the first line of defence'
            window.requestFileSystem = window.requestFileSystem || window.webkitRequestFileSystem
            @_getDirEntryRawName(document.numeric.url.base.fs, {create:true})
            .then( => @getDirEntry(document.numeric.path.result, {create:true}))
            .then( => @getDirEntry(document.numeric.path.activity, {create:true}))
            .then( => @getDirEntry(document.numeric.path.body, {create:true}))
            .then( => @getDirEntry(document.numeric.path.meta, {create:true}))
            .then( => @getDirEntry(document.numeric.path.persistence, {create:true}))

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

        _inCordova: -> ( typeof LocalFileSystem != 'undefined' )
        _printEntries: (entries) ->
            console.log('entries:')
            for entry in entries
                console.log(entry.name)

        _requestQuota: ->
            deferred = $q.defer()
#            navigator.webkitPersistentStorage.requestQuota(
#                10*1024*1024
#                (bytes) ->
#                    deferred.resolve(bytes)
#                (status) ->
#                    deferred.reject(status)
#            )
# using temporary storage for Chrome:
# 1. no scary message "... wants to permanently store large amount of data..." - scares people
            deferred.resolve(1)

            deferred.promise

        getFileSystem: =>
            deferred = $q.defer()
            if @fileSystem != undefined
                deferred.resolve(@fileSystem)
            else if @_inCordova()
               window.requestFileSystem(
                LocalFileSystem.PERSISTENT
                0
                (fs) =>
                    @fileSystem = fs
                    deferred.resolve(fs)
                @_errorHandler(deferred))
            else
                console.log('running in a browser')
                @_requestQuota()
                .then (bytes) =>
                   window.requestFileSystem(
                    #window.PERSISTENT # switched temporary for Chrome
                    window.TEMPORARY
                    bytes
                    (fs) =>
                        @fileSystem = fs
                        deferred.resolve(fs)
                    @_errorHandler(deferred))
                .catch (status) => deferred.reject(status)
            deferred.promise

        # get Files and Dirs from here
        _getDirEntryRawName: (dirName, options) ->
            console.log('getting dirEntry: ' + dirName)
            deferred = $q.defer()
            @getFileSystem()
            .then (fs) =>
                if dirName == '/'
                    deferred.resolve(fs.root)
                else
                    fs.root.getDirectory(
                        dirName
                        options
                        (dirEntry) -> deferred.resolve(dirEntry)
                        @_errorHandler(deferred))
            .catch (status) -> deferred.reject(status)
            deferred.promise

        __getFileEntryRawName: (fileName, options) ->
            console.log('getting fileEntry: ' + fileName)
            deferred = $q.defer()
            @getFileSystem()
            .then (fs) =>
                fs.root.getFile(
                    fileName
                    options
                    (fileEntry) -> deferred.resolve(fileEntry)
                    @_errorHandler(deferred))
            .catch (status) -> deferred.reject(status)

            deferred.promise

        getDirEntry: (dirName, options) -> @_getDirEntryRawName(document.numeric.url.base.fs + dirName, options)
        getFileEntry: (fileName, options) -> @__getFileEntryRawName(document.numeric.url.base.fs + fileName, options)

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
            .then (fileEntry) =>
                fileEntry.createWriter(
                    (fileWriter) -> deferred.resolve(fileWriter)
                    @_errorHandler(deferred))
            .catch (status) =>
                deferred.reject(status)
            deferred.promise
        getFileReader: (fileName) ->
            deferred = $q.defer()
            @getFileEntry(fileName, {create: false})
            .then (fileEntry) ->
                fileEntry.file(
                    (file) ->
                        reader = new FileReader()
                        reader.onloadend = (evt) -> deferred.resolve(evt.target.result)
                        reader.readAsText(file)
                    (fail) -> deferred.reject(fail))
            .catch (status) ->
                deferred.reject(status)
            deferred.promise

        # write/read strings to/from file
        prepareText: (textData) ->
            if textData == undefined
                textData = ''
            if @_inCordova()
                textData
            else
                new Blob([textData], {type: 'text/plain'})

        writeToFile: (fileName, textData) ->
            deferred = $q.defer()
            @getFileWriter(fileName)
            .then (fileWriter) =>
                console.log('obtained filewriter for: ' + fileName)
                preparedText = @prepareText(textData)
                fileWriter.seek(0)
                window.fwfw = fileWriter
                fileWriter.onwriteend = () ->
                    console.log('finished writing')
                    deferred.resolve()
                fileWriter.onerror = (e) ->
                    deferred.reject([1, e])
                fileWriter.write(preparedText)
            .catch (status) =>
                deferred.reject(status)
            deferred.promise

        readFromFile: (fileName) ->
            deferred = $q.defer()
            @getFileReader(fileName)
            .then (data) =>
                deferred.resolve(data)
            .catch (status) =>
                deferred.reject(status)
            deferred.promise

        #######################################

        writeDataToFile: (fileName, buffer, getHash) =>
            deferred = $q.defer()
            dataAsString = JSON.stringify(buffer)
            @writeToFile(fileName, dataAsString)
            .then (data) =>
                if getHash
                    deferred.resolve(md5.createHash(dataAsString + @salt))
                else
                    deferred.resolve('ok')
            .catch (status) =>
                deferred.reject(status)
            deferred.promise

        readDataFromFile: (fileName, checkHash) =>
            deferred = $q.defer()
            @readFromFile(fileName)
            .then (data) =>
                    if checkHash && checkHash != md5.createHash(data + @salt)
                        @tryDeleteFile(fileName)
                        deferred.resolve('mismatch')
                    else
                        deferred.resolve(JSON.parse(data))
            .catch (status) =>
                deferred.reject(status)
            deferred.promise

        tryDeleteFile: (fileName) =>
            deferred = $q.defer()
            @getFileEntry(fileName, {create: false})
            .then(
                (fileEntry) =>
                    fileEntry.remove(
                        (success) => deferred.resolve('removed')
                        (status) => deferred.resolve('could not remove, but it is alright')
                    )
                (status) -> deferred.resolve('could not remove, but it is alright')
            )
            deferred.promise

    new FS()
])