document.numeric.numericTasks['QuizDEV'] =
{
    // REQUIRED FIELD
    name: 'Quiz',
    description: 'Practice multiplying numbers',
    authorName: 'Renat Bekbolatov',
    authorEmail: 'renatbek@gmail.com',
    complexity: 50,

    // REQUIRED FIELD - follow pattern
    parameters: {
        level: {
                name: 'level',
                description: 'How difficult should the questions be?',
                type: 'discrete',
                levels: [ 'easy', 'medium', 'hard'],
                selectedValue: 'medium'
        },
        quantity: {
                name: 'quantity',
                description: 'How many questions to put in this task?',
                type: 'discrete',
                levels: [ 20, 50 ],
                selectedValue: 20
        }
    },

    questionType: 'text',
    answerType: 'multiple',

    // REQUIRED FIELD - follow pattern
    createNextQuestion: function() {
        var self = this;
        var _randomInt = function (lower, upper) { return Math.floor((Math.random() * (upper - lower + 1)) + lower) };
        var _isLevel = function (level) { return self.parameters.level.selectedValue == level};

        var min = 1;
        var max = 9;
        if (_isLevel('easy')) {
            min = 1;
            max = 9;
        } else if (_isLevel('medium')) {
            min = 11;
            max = 50;
        } else {
            min = 21;
            max = 99;
        }

        var partA = _randomInt(min, max);
        var partB = _randomInt(min, max);

        var statement = partA + ' x ' + partB + " = ";
        var correctAnswer = partA * partB;

        return {
            statement: statement,
            checkAnswer: function(answer) { return answer == correctAnswer }
        }
    }
};
