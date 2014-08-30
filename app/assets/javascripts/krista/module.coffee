angular.module 'Krista', []


.factory "KristaQuestions",
    [ 'M01', 'M02', 'M03', 'M04', 'M05', 'M06', 'M07', 'M08', 'M09', 'M10', 'M11', 'M12', 'M13', 'M14', 'M15', 'M16', 'M17', 'M18', 'M19', 'M20','M21', 'M22', 'M23', 'M24', 'M25', 'M26', 'M27', 'M28', 'M29', 'M30',
        (M01, M02, M03, M04, M05, M06, M07, M08, M09, M10, M11, M12, M13, M14, M15, M16, M17, M18, M19, M20, M21, M22, M23, M24, M25, M26, M27, M28, M29, M30 ) ->

            class KristaQuestions
                constructor: ->
                    @questions = [M01, M02, M03, M04, M05, M06, M07, M08, M09, M10,M11, M12, M13, M14, M15, M16, M17, M18, M19, M10,M21, M22, M23, M24, M25, M26, M27, M28, M29, M30]

                generate: (n) ->
                    q = @questions[n - 1]
                    if q == undefined || q.generate == undefined
                        return [ [ 'question has not been implemented'], '' ]
                    q.generate()

            k = new KristaQuestions()
            document.numeric.modules.KristaQuestions = k
            k
    ]
