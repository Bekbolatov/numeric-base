document.numeric.numericTasks['Multiplication'] =
{
    // REQUIRED FIELD
    name: 'Multiplication',
    description: 'Practice multiplying numbers',
    authorName: 'Renat Bekbolatov',
    authorEmail: 'renatbek@gmail.com',
    complexity: 20,


    // REQUIRED FIELD - follow pattern
    parameters: {
        p10_quantity: {
                name: 'quantity',
                description: 'How many questions to put in this task?',
                type: 'discrete',
                levels: [ 10, 20, 50 ],
                selectedValue: 20
        },
        p20_level: {
                name: 'level',
                description: 'How difficult should the questions be?',
                type: 'discrete',
                levels: [ 'easy', 'medium', 'hard'],
                selectedValue: 'medium'
        }
    },

    questionType: 'text',
    answerType: 'numeric',

    // REQUIRED FIELD - follow pattern
    createNextQuestion: function(numberOfQuestionsSoFar) {
        var self = this;
        var _randomInt = function (lower, upper) { return Math.floor((Math.random() * (upper - lower + 1)) + lower) };
        var _isLevel = function (level) { return self.parameters.p20_level.selectedValue == level};
        var _shouldFinish = function (numQuestions) { return self.parameters.p10_quantity.selectedValue <= numQuestions};

        if (_shouldFinish(numberOfQuestionsSoFar)) {
            return undefined
        }

        var min, max;

        if (_isLevel('easy')) {
            min = 2;
            max = 9;
        } else if (_isLevel('medium')) {
            min = 2;
            max = 30;
        } else {
            min = 5;
            max = 99;
        }

        var partA = _randomInt(min, max);
        var partB = _randomInt(min, max);

        var statement = partA + ' x ' + partB;
        var correctAnswer = partA * partB;

        return {
            statement: statement,
            checkAnswer: function(answer) { return answer == correctAnswer }
        }
    }
};
