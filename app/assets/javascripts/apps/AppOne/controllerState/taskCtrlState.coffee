angular.module('AppOne')

.factory "TaskCtrlState", ['$location', ($location) ->
    class TaskCtrlState
        isOnOptions: false
        isOnReviewLast: false
        isOnNote: false
        isOnExit: false
        optionsChanged: false
        noteToAddDestinationCurrent: true

        setScope: (@scope) ->
            @isOnOptions = false
            @isOnReviewLast = false
            @isOnNote = false
            @isOnExit = false
            @optionsChanged = false
            @noteToAddDestinationCurrent = true
            @

        backButton: () ->
            if @isOnNote && @noteToAddDestinationCurrent
                @scope.backToActivity({note: true})
            else if @isOnNote && !@noteToAddDestinationCurrent
                @scope.toPrevQuestion({note: true})
            else if @isOnOptions || @isOnReviewLast || @isOnExit
                @scope.backToActivity()
            else
                @scope.toExitWindow()
            @scope.$digest()


    new TaskCtrlState()

]