document.numeric.numericTasks['Division'] =
{
    name: 'Division',
    description: 'Practice dividing numbers',
    authorName: 'Renat Bekbolatov',
    authorEmail: 'renatbek@gmail.com',
    complexity: 25,

    parameters: {

        p10_quantity: {
                name: 'quantity',
                description: 'How many questions to put in this task?',
                type: 'discrete',
                levels: [ 20, 50 ],
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
            max = 50;
        } else {
            min = 21;
            max = 99;
        }

        var partA = _randomInt(min, max);
        var partB = _randomInt(min, max);

        var statement = (partA*partB) + ' / ' + partB;
        var correctAnswer = partA;

        return {
            statement: statement,
            checkAnswer: function(answer) { return answer == correctAnswer }
        }
    }
};
