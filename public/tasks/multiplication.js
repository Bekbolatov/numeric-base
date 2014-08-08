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

    // REQUIRED FIELD - follow pattern
    createNextQuestion: function() {
        var self = this;
        var _randomInt = function (lower, upper) { return Math.floor((Math.random() * (upper - lower + 1)) + lower) };
        var _isLevel = function (level) { return self.parameters.level.selectedValue == level};

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

        var statement = partA + ' x ' + partB + " = ";
        var correctAnswer = partA * partB;

        return {
            statement: statement,
            checkAnswer: function(answer) { return answer == correctAnswer }
        }
    }
};
