angular.module('EarnIt')

.factory("Channels", ['$q', '$location', 'Settings', 'ServerHttp', 'PersistenceManager', ($q, $location, Settings, ServerHttp,PersistenceManager ) ->
    class Channels
        current: {}
        newFirst: 0
        constructor: () ->
            @persister = PersistenceManager.localStoreBlockingDictionaryPersister(document.numeric.key.channelActivities)
            init = @persister.init()

        # live
        _uriActivities: -> Settings.get('mainServerAddress') + document.numeric.path.list
        _uriChannels: -> Settings.get('mainServerAddress') + document.numeric.path.channels
        getChannelActivities: (start, size, searchTerm) ->

            deferred = $q.defer()
            st = ""
            if searchTerm != undefined
                st = "&q=" + searchTerm.trim()

            ServerHttp.get(@_uriActivities() + "?chid=" + @current.id + "&st=" + start + "&si=" + size + st)
            .then (response) =>
                @persister.set(@makeKey(@current.id, start, size, searchTerm), response.data.activities)
                deferred.resolve(response)
            .catch (status) => deferred.reject(status)

            deferred.promise

        getChannels: (start, size, searchTerm) ->
            st = ""
            if searchTerm != undefined
                st = "&q=" + searchTerm.trim()

            ServerHttp.get(@_uriChannels() + "?st=" + start + "&si=" + size + st)



        # cache
        makeKey: (chid, start, size, searchTerm) ->
            if searchTerm != undefined
                searchTerm = searchTerm.trim()
            else
                searchTerm = ''
            '' + chid + ':' + start + ':' + size + ':' + searchTerm
        getChannelActivitiesFromCache: (start, size, searchTerm) ->
            cachedVersion = {}
            activities = @persister.get(@makeKey(@current.id, start, size, searchTerm))
            if activities != undefined || activities != null
                cachedVersion.activities = activities
            cachedVersion

        setCurrentChannel: (id, name, back) ->
            @current.id = id
            @current.name = name
            if back == undefined
                back = '#/'
            @current.back = back
            @newFirst = 0

        navigateToChannel: (id, name, back) ->
            @setCurrentChannel(id, name, back)
            $location.path('/channel')


    new Channels()
])
