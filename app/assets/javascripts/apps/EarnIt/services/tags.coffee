angular.module('EarnIt')

.factory "Tags", ['$location', 'Settings', 'ServerHttp', ($location, Settings, ServerHttp ) ->
    class Tags
        hasTags: -> false
        navigateToTags: () ->
            $location.path('/tags')

    new Tags()
    ]