
class ProblemSet
    constructor: () ->
        @previousQuestion = 0
        @units =
            1: new M01()
            2: new M02()
            3: new M03()
            4: new M04()
            5: new M05()
            6: new M06()
            7: new M07()
            8: new M08()
            9: new M09()
            10: new M10()
            11: new M11()
            12: new M12()
            13: new M13()
            14: new M14()
            15: new M15()
            16: new M16()
            17: new M17()
            18: new M18()
            19: new M19()
            20: new M20()
            21: new M21()
            22: new M22()
            23: new M23()
            24: new M24()
            25: new M25()
            26: new M26()
            27: new M27()
            28: new M28()
            29: new M29()
            30: new M30()
    parameters:
        p10_serveOrder:
                name: 'nextproblem'
                description: 'Order of questions:'
                type: 'discrete'
                levels: ['same', 'random', 'sequential']
                selectedValue: 'random'
        p20_fixedProblemNumber:
                name: 'problemnumber'
                description: 'Jump to question number:'
                type: 'discrete'
                levels: [ 1,2,3,4,5,6,7,8,9,10, 11,12,13,14,15,16,17,18,19,20, 21,22,23,24,25,26,27,28,29,30 ]
                jump: true
                selectedValue: undefined

    getOrder = () => @parameters.p10_serveOrder.selectedValue
    getProblemNumber = () => @parameters.p20_fixedProblemNumber.selectedValue
    createNextQuestion: () =>

        if  @parameters.p20_fixedProblemNumber.selectedValue != undefined
            num = @parameters.p20_fixedProblemNumber.selectedValue
        else
            if @parameters.p10_serveOrder.selectedValue == 'random'
                num = 1 + Math.random()*30 | 0
            else if @parameters.p10_serveOrder.selectedValue == 'sequential'
                num = @previousQuestion + 1
                if num > 30
                    return undefined
            else #if (self.parameters.p10_serveOrder.selectedValue == 'same') {
                num = @previousQuestion


        @parameters.p20_fixedProblemNumber.selectedValue = undefined
        @previousQuestion = num

        qa = @units[num].generate(num)

        qq =
            statement: qa[0][0]
            checkAnswer: (answer) -> answer == qa[1]
            getAnswer: () -> qa[1]
        if qa[0].length > 1
            qq.answerType = 'multiple'
            qq.choices = qa[0][1]
        else
            qq.answerType = 'numeric'

        qq

document.numeric.numericTasks['com.sparkydots.numeric.tasks.ssat.c.q00'] = new ProblemSet()
