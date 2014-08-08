document.numeric.numericTasks['Addition'] =
{
    name: 'Addition',
    description: 'Practice adding numbers',
    authorName: 'Renat Bekbolatov',
    authorEmail: 'renatbek@gmail.com',
    complexity: 10,

    parameters: {
        level: {
                name: 'level',
                description: 'How difficult should the questions be?',
                type: 'discrete',
                levels: [ 'trivial', 'easy', 'medium', 'hard'],
                selectedValue: 'medium'
        },
        quantity: {
                name: 'quantity',
                description: 'how many questions to put in this task?',
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

        var min = 1;
        var max = 9;

        if (_isLevel('trivial')) {
            min = 1;
            max = 9;
        } else if (_isLevel('easy')) {
            min = 5;
            max = 50;
        } else if (_isLevel('medium')) {
            min = 21;
            max = 99;
        } else {
            min = 111;
            max = 999;
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
