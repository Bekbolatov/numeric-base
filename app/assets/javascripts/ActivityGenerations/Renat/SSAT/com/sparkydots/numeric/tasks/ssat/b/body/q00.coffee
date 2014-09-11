document.numeric.numericTasks['com.sparkydots.numeric.tasks.ssat.b.q00'] =
    variables:
        previousQuestion: 0
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
                selectedValue: undefined
    createNextQuestion: () ->
        self = this
        previousQuestion = () -> self.variables.previousQuestion
        getOrder = () -> self.parameters.p10_serveOrder.selectedValue
        getProblemNumber = () -> self.parameters.p20_fixedProblemNumber.selectedValue

        KristaQuestions = document.numeric.modules.KristaQuestions

        if  self.parameters.p20_fixedProblemNumber.selectedValue != undefined
            num = self.parameters.p20_fixedProblemNumber.selectedValue
        else
            if self.parameters.p10_serveOrder.selectedValue == 'random'
                num = Math.random()*30 | 0
            else if self.parameters.p10_serveOrder.selectedValue == 'sequential'
                num = self.variables.previousQuestion + 1
                if num > 30
                    return undefined
            else #if (self.parameters.p10_serveOrder.selectedValue == 'same') {
                num = self.variables.previousQuestion


        num = 15

        self.parameters.p20_fixedProblemNumber.selectedValue = undefined
        self.variables.previousQuestion = num

        qa = KristaQuestions.generate(num)

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
