document.numeric.numericTasks['Subtraction'] =
{
    name: 'Subtraction',
    description: 'Practice subtracting numbers',
    authorName: 'Renat Bekbolatov',
    authorEmail: 'renatbek@gmail.com',
    complexity: 15,


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
                levels: [ 10, 20, 50 ],
                selectedValue: 20
        }
    },

    questionType: 'text',
    answerType: 'numeric',

    createNextQuestion: function() {
        var self = this;

        var _randomInt = function (lower, upper) { return Math.floor((Math.random() * (upper - lower + 1)) + lower) };
        var _isLevel = function (level) { return self.parameters.level.selectedValue == level};

        var min, max;

        if (_isLevel('easy')) {
            min = 2;
            max = 50;
        } else if (_isLevel('medium')) {
            min = 11;
            max = 99;
        } else {
            min = 111;
            max = 999;
        }

        var partA = _randomInt(min, max);
        var partB = _randomInt(min, max);

        var statement = (partA + partB) + ' - ' + partB + " = ";
        var correctAnswer = partA;

        return {
            statement: statement,
            checkAnswer: function(answer) { return answer == correctAnswer }
        }
    }
};
