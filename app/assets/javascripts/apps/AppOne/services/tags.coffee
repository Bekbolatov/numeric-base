angular.module('AppOne')

.factory "Tags", ['$location', 'Settings', 'ServerHttp', ($location, Settings, ServerHttp ) ->
    class Tags
        hasTags: -> false
        navigateToTags: () ->
            $location.path('/tags')

    new Tags()
    ]