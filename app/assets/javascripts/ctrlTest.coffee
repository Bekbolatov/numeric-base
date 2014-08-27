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

.controller 'SampleQuestionCtrl', ['$scope', '$rootScope', '$routeParams', '$http', 'md5', \
        'KristaQuestion', 'KristaUtil', ($scope, $rootScope, $routeParams, $http, md5, KristaQuestion, KristaUtil ) ->
    $scope.twoNames = KristaUtil.randomPairNames()
    $scope.cgen = KristaQuestion['questionType04Composer']() # questionType04Composer()
    console.log($scope.c)
]

.controller 'SampleQuestionOriginalCtrl', ['$scope', '$rootScope', '$routeParams', '$http', 'md5', 'FS', ($scope, $rootScope, $routeParams, $http, md5, FS ) ->

    p_kids = [ [ ['boy', 'boys'], [ 'girl', 'girls'] ], ['kid', 'children'] ]

    p_birds = [ [ ['red bird', 'red birds'], [ 'blue bird', 'blue birds'] ], ['bird', 'birds'] ]
    p_balls = [ [ ['red ball', 'red balls'], [ 'green ball', 'green balls'] ], ['ball', 'balls'] ]
    p_marbles = [ [ ['red marble', 'red marbles'], [ 'blue marble', 'blue marbles'] ], ['marble', 'marbles'] ]
    p_pens = [ [ ['pencil', 'pencils'], [ 'pen', 'pens'] ], ['pen or pencil', 'pens and pencils'] ]
    p_apples = [ [ ['apple', 'apples'], [ 'banana', 'bananas'] ], ['fruit', 'fruits'] ]
    p_booksAbout = [ [ ['book about computers', 'books about computers'], [ 'book about food', 'books about food'] ], ['book', 'books'] ]

    p = [p_birds, p_balls, p_marbles, p_pens, p_apples, p_booksAbout]

    g_jazzClass = [ ['class', 'jazz dance class'], 'in the' ]
    g_tree = [ ['tree', 'tall'], 'on the', 'sitting' ]

    g_ = [ [''], '' ]
    g_class = [ ['class'], 'in the' ]
    g_box = [ ['box'], 'in the' ]
    g_table = [ ['table'], 'on the' ]
    g_room = [ ['room'], 'in the' ]

    g = [g_, g_class, g_box, g_table, g_room]

    random = (a, b) -> a + ( Math.random() * (b-a) ) | 0 # a, a+1, ... b-1.
    rand = (l) -> ( Math.random() * l ) | 0
    rnd = (lis) -> lis[rand(lis.length)]

    # util - prettify sentence
    prettify = (text) ->
        afterSpaced = '.,;-!?'
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



    r1 = random(1,7)
    r2 = random(1,7)
    m = random(2,7)

    dr = {
        location: rnd(g)
        elements: rnd(p)
        ratio : [r1, r2]
        numbers: [r1*m, r2*m]
    }

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
        # red bird(s)/blue bird(s)
        c.element = (i) -> data.elements[0][i][0]
        c.elements = (i) -> data.elements[0][i][1]
        # bird/birds
        c.item = -> data.elements[1][0]
        c.items = -> data.elements[1][1]
        # ... (sitting) (on the) (tall) (tree)
        c.inSet = (acting, pink) ->
            output = ''
            if acting && data.location[2]
                output += data.location[2] + ' '
            output += data.location[1]
            if pink && data.location[0].length > 1
                output += data.location[0][1] + ' '
            output + data.location[0][0]

        ## COMBO LEVEL 1
        # there are 5 boys ...
        c.thereAre = (i) ->
            output = 'there '
            if c.number(i) == 1
                output += 'is 1 ' + c.element(i)
            else
                output += 'are ' + c.number(i) + ' ' + c.elements(i)
            output
        c.thereAreTotal = ->
            total = c.numberTotal()
            output = 'there '
            if total == 1
                output += 'is 1 ' + c.item()
            else
                output += 'are ' + total + ' ' + c.items()
            output
        c.ratioIs = (there) ->
            if there == undefined || there == ''
                'the ratio of ' + c.elements(0) + ' to ' + c.elements(1) + ' is ' + c.ratio()
            else
                'the ratio of ' + c.elements(0) + ' to ' + c.elements(1) + ' ' + there + ' is ' + c.ratio()
        # QUESTIONS: how many red birds are there?
        c.howMany = (i) -> 'how many ' + c.elements(i) + ' are there'
        c.howManyTotal = -> 'how many ' + c.items() + ' are there'

        ## COMBO LEVEL 2
        # STATEMENTS: there are 5 blue birds in the box
        c.ratioIsInSet = (acting, pink) -> c.ratioIs(c.inSet(acting, pink))
        c.thereAreInSet = (i, acting, pink) -> c.thereAre(i) + ' ' + c.inSet(acting, pink)
        c.thereAreTotalInSet = (acting, pink) -> c.thereAreTotal() + ' ' + c.inSet(acting, pink)


        # Questions: how many red birds are there in the box?
        c.howManyInSet = (i, acting, pink) -> c.howMany(i) + ' ' + c.inSet(acting, pink)
        c.howManyTotalInSet = (acting, pink) -> c.howManyTotal() + ' ' + c.inSet(acting, pink)

        # ... If/./However/What if/Assume/Imagine ..., ...? (simple combinations of strings)
        c.AifBthenwhatC = (A, B, C, v) ->
            if v != undefined || v == ''
                output = A + '. ' + v + ' ' + B + ', ' + C + '?'
            else
                output = A + '. ' + B + '. ' + C + '?'
            c.prettify(output)
        c.AwhatCifB = (A, B, C, v) ->
            if v == undefined || v == ''
                v = 'if'
            output = A + '. ' + C + ' ' + v + ' ' + B + '?'
            c.prettify(output)
        c.ifBthenwhatC = (B, C, v) ->
            if v != undefined || v == ''
                output = v + ' ' + B + ', ' + C + '?'
            else
                output = B + '. ' + C + '?'
            c.prettify(output)
        c.generate = ->
            s = ['AifBthenwhatC', 'AwhatCifB']
            v = ['if', '']

            c[rnd(s)]( c.ratioIsActingInSet(),  c.thereAre(0), c.howManyInSet(1),     rnd(v))

        c

    $scope.c = composer(dr)
]