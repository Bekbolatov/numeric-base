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
                type: 'discrete',
                levels: [ 'easy', 'medium', 'hard'],
                selectedValue: 'medium'
        },
        quantity: {
                name: 'quantity',
                type: 'discrete',
                levels: [ 20, 50 ],
                selectedValue: 20
        }
    },

    questionType: 'text',
    answerType: 'numeric',

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

        var statement = partA + ' + ' + partB + " = ";
        var correctAnswer = partA + partB;

        return {
            statement: statement,
            checkAnswer: function(answer) { return answer == correctAnswer }
        }
    }
};
