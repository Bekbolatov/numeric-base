angular.module('AppOne')

.factory("Channels", ['$location', 'Settings', 'ServerHttp', ($location, Settings, ServerHttp ) ->
    class Channels
        current: {}
        newFirst: 0

        _uriActivities: -> Settings.get('mainServerAddress') + document.numeric.path.list
        _uriChannels: -> Settings.get('mainServerAddress') + document.numeric.path.channels

        getChannelActivities: (start, size, searchTerm) ->
            st = ""
            if searchTerm != undefined
                st = "&q=" + searchTerm.trim()

            ServerHttp.get(@_uriActivities() + "?chid=" + @current.id + "&st=" + start + "&si=" + size + st)

        getChannels: (start, size, searchTerm) ->
            st = ""
            if searchTerm != undefined
                st = "&q=" + searchTerm.trim()

            ServerHttp.get(@_uriChannels() + "?st=" + start + "&si=" + size + st)

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
