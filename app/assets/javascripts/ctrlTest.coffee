angular.module('AppOne')

.controller 'TestCtrl', ['$scope', '$rootScope', '$routeParams', '$http', 'md5', 'FS', ($scope, $rootScope, $routeParams, $http, md5, FS ) ->

    $scope.showScriptsInHead = () ->
        tags = document.getElementsByTagName('script')
        $scope.scripts = []
        for tag in tags
            if tag.id != undefined && tag.id != ''
                $scope.scripts.push(tag)

    $scope.getHttpsData = () ->
             $http.get('https://www.vicinitalk.com/api/v1/post/375/?format=json')
             .then(
                (response) ->
                    console.log(response)
                    $scope.httpsdata = response.data
                (status) -> console.log('error: ' + status)
             )

    #   read write
    $scope.writeToFile = () -> FS.writeToFile('testdata.txt', 'hsellodata')
    $scope.readFromFile = () ->
        FS.readFromFile('testdata.txt')
        .then(
            (data) -> $scope.readData = data
        )
    $scope.getContentsRaw = (path) -> FS.getContents(path)

    $scope.getFromLocal = (key) -> $scope.localData = window.localStorage.getItem(key)
    $scope.testmd5 = (txt) -> $scope.localData = md5.createHash(txt)

    ]


.filter '', ->
    (input) ->
        if input == undefined
            ''
        else
            input.substring(0,1).toUpperCase()+input.substring(1)

.controller 'SampleQuestionCtrl', ['$scope', '$rootScope', '$routeParams', '$http', 'md5', 'FS', ($scope, $rootScope, $routeParams, $http, md5, FS ) ->

    p_kids = [ [ ['boy', 'boys'], [ 'girl', 'girls'] ], ['kid', 'children'] ]
    p_birds = [ [ ['red bird', 'red birds'], [ 'blue bird', 'blue birds'] ], ['bird', 'birds'] ]

    g_jazzClass = [ ['class', 'jazz dance class'], 'in the' ]
    g_tree = [ ['tree', 'tall'], 'on the', 'sitting' ]


    d = {
        location : g_jazzClass
        elements : p_kids
        ratio : [1, 2]
        numbers : [7, 14]
    }
    d2 = {
        location : g_tree
        elements : p_birds
        ratio : [1, 2]
        numbers : [7, 14]
    }
    d3 = {
        location : g_tree
        elements : p_kids
        ratio : [1, 2]
        numbers : [7, 14]
    }
    composer = (data) ->
        c = {}
        c.ratio = -> data.ratio.join(':')
        c.number = (i) -> data.numbers[i]
        c.numberTotal = () ->
            total = 0
            for n in data.numbers
                total += n
            total
        # util - prettify sentence
        c.prettify = (text) ->
            afterSpaced = '.,;:-!?'
            sentenceStop = '.!?'
            az = 'abcdefghijklmnopqrstuvwxyz'
            output = ''
            previousLetter = undefined
            upperCaseNext = true
            skipBlack = true
            for letter in text
                append = letter.toLowerCase()
                if az.indexOf(append) > -1 && upperCaseNext
                    append = letter.toUpperCase()
                    upperCaseNext = false
                if sentenceStop.indexOf(letter) > -1
                    upperCaseNext = true
                if afterSpaced.indexOf(letter) > -1
                    output += letter + ' '
                    append = ''
                if letter == ' '
                    if skipBlank
                        append = ''
                    skipBlank = true
                else
                    skipBlank = false
                output += append
            output
        # red bird(s)/blue bird(s)
        c.element = (i) -> data.elements[0][i][0]
        c.elements = (i) -> data.elements[0][i][1]
        # bird/birds
        c.item = -> data.elements[1][0]
        c.items = -> data.elements[1][1]
        # ... in the class
        c.inSet = -> data.location[1] + ' ' + data.location[0][0]
        c.inPinkSet = ->
            if data.location[0].length > 1
                data.location[1] + ' ' + data.location[0][1] + ' ' + data.location[0][0]
            else
                c.inSet()
        c.actingInSet = ->
            if data.location[2]
                data.location[2] + ' ' + c.inSet()
            else
                c.inSet()
        c.actingInPinkSet = ->
            if data.location[2]
                data.location[2] + ' ' + c.inPinkSet()
            else
                c.inPinkSet()
        # there are 5 blue birds ...
        c.thereAre = (i) ->
            output = 'there '
            if c.number(i) == 1
                output += 'is 1 ' + c.element(i)
            else
                output += 'are ' + c.number(i) + ' ' + c.elements(i)
            output
        c.thereAreTotal = (i) ->
            total = c.numberTotal()
            output = 'there '
            if total == 1
                output += 'is 1 ' + c.item()
            else
                output += 'are ' + total + ' ' + c.items()
            output
        c.ratioIs = (there) ->
            if there == undefined
                'the ratio of ' + c.elements(0) + ' to ' + c.elements(1) + ' is ' + c.ratio()
            else
                'the ratio of ' + c.elements(0) + ' to ' + c.elements(1) + ' ' + there + ' is ' + c.ratio()

        # STATEMENTS: there are 5 blue birds in the box
        c.ratioIsInSet = () -> c.ratioIs(c.inSet())
        c.ratioIsActingInSet = () -> c.ratioIs(c.actingInSet())
        c.ratioIsInPinkSet = () -> c.ratioIs(c.inPinkSet())
        c.ratioIsActingInPinkSet = () -> c.ratioIs(c.actingInPinkSet())

        c.thereAreInSet = (i) -> c.thereAre(i) + ' ' + c.inSet()
        c.thereAreInPinkSet = (i) -> c.thereAre(i) + ' ' + c.inPinkSet()

        c.thereAreTotalInSet = () -> c.thereAreTotal(i) + ' ' + c.inSet()
        c.thereAreTotalInPinkSet = () -> c.thereAreTotal(i) + ' ' + c.inPinkSet()

        # QUESTIONS: how many red birds are there in the box?
        c.howManyInSet = (i) -> 'how many ' + c.elements(i) + ' are there ' + c.inSet()
        c.howManyActingInSet = (i) -> 'how many ' + c.elements(i) + ' are there ' + c.actingInSet()
        c.howManyTotalInSet = -> 'how many ' + c.items() + ' are there ' + c.inSet()
        c.howManyTotalActingInSet = -> 'how many ' + c.items() + ' are there ' + c.actingInSet()

        # ... If/./However/What if/Assume/Imagine ..., ...? (simple combinations of strings)
        c.AifBthenwhatC = (A, B, C, v) ->
            if v != undefined
                output = A + '. ' + v + ' ' + B + ', ' + C + '?'
            else
                output = A + '. ' + B + '. ' + C + '?'
            c.prettify(output)
        c.AwhatCifB = (A, B, C, v) ->
            if v == undefined
                v = 'if'
            output = A + '. ' + C + ' ' + v + ' ' + B + '?'
            c.prettify(output)
        c.ifBthenwhatC = (B, C, v) ->
            if v != undefined
                output = v + ' ' + B + ', ' + C + '?'
            else
                output = B + '. ' + C + '?'
            c.prettify(output)
        c

    $scope.c = composer(d3)
]