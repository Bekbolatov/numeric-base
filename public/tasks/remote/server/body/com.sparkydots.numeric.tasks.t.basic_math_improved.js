document.numeric.numericTasks['com.sparkydots.numeric.tasks.t.basic_math_improved'] =
{
    answerType: 'numeric',

    parameters: {
        p10_operation: {
                name: 'operation',
                description: 'What operation to practice?',
                type: 'discrete',
                levels: [ 'addition', 'subtraction', 'multiplication', 'division', 'square root'],
                selectedValue: 'addition'
        },
        p20_level: {
                name: 'level',
                description: 'How difficult should the questions be?',
                type: 'discrete',
                levels: [ 'easy', 'medium', 'hard'],
                selectedValue: 'easy'
        }
    },


    createNextQuestion: function() {
        var self = this;
        var _randomInt = function (lower, upper) { return Math.floor((Math.random() * (upper - lower + 1)) + lower) };
        var _isLevel = function (level) { return self.parameters.p20_level.selectedValue == level};
        var _isOp = function (operation) { return self.parameters.p10_operation.selectedValue == operation};

        var min, max;


        var statement, correctAnswer;

        if (_isOp('addition')) {
            if (_isLevel('easy')) {
                min = 3;
                max = 10;
            } else if (_isLevel('medium')) {
                min = 21;
                max = 99;
            } else {
                min = 111;
                max = 999;
            }
            var partA = _randomInt(min, max);
            var partB = _randomInt(min, max);
            statement = partA + ' + ' + partB;
            correctAnswer = partA + partB;
        } else if (_isOp('subtraction')) {
            if (_isLevel('easy')) {
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
            statement = (partA + partB) + ' - ' + partB;
            correctAnswer = partA;
        } else if (_isOp('multiplication')) {
            if (_isLevel('easy')) {
                min = 2;
                max = 20;
            } else if (_isLevel('medium')) {
                min = 5;
                max = 50;
            } else {
                min = 11;
                max = 99;
            }
            var partA = _randomInt(min, max);
            var partB = _randomInt(min, max);
            statement = partA + ' x ' + partB;
            correctAnswer = partA * partB;
        } else if (_isOp('division')) {
            if (_isLevel('easy')) {
                min = 2;
                max = 20;
            } else if (_isLevel('medium')) {
                min = 5;
                max = 50;
            } else {
                min = 11;
                max = 99;
            }
            var partA = _randomInt(min, max);
            var partB = _randomInt(min, max);
            statement = (partA*partB) + ' ÷ ' + partB;
            correctAnswer = partA;
        } else if (_isOp('square root')) {
            if (_isLevel('easy')) {
                min = 2;
                max = 20;
            } else if (_isLevel('medium')) {
                min = 5;
                max = 50;
            } else {
                min = 11;
                max = 99;
            }
            var partA = _randomInt(min, max);
            statement = '<span class="activity-math-sq" style="font-size: 125%;">√</span><span style="border-top:2px solid; padding:0 0.1em;">' + (partA*partA) + '</span>';
            correctAnswer = partA;
        } else {
            console.log("some unrecognized operation")
            statement = "unrecognized operation"
            correctAnswer = 0;
        }

        return {
            statement: statement,
            checkAnswer: function(answer) { return answer == correctAnswer }
        }
    }
};