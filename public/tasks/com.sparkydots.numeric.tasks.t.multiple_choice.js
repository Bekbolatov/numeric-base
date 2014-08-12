document.numeric.numericTasksList.push('com.sparkydots.numeric.tasks.t.multiple_choice');
document.numeric.numericTasks['com.sparkydots.numeric.tasks.t.multiple_choice'] =
{
    name: 'Odd One Out (KidPack 1)',
    description: 'Practice multiplying numbers',
    authorName: 'Renat Bekbolatov',
    authorEmail: 'renatbek@gmail.com',
    dataFile: 'multipleChoice_1.data',
    questionBank: [],
    answerType: 'multiple',
    complexity: 60,


    // follow pattern:
    // parameters: {  param1: {}, param2: {} },  or not set if no params

    // REQUIRED FIELD
    createNextQuestion: function() {
        var self = this;
        self.questionBank = self.questionBankMock;

        var _randomInt = function (lowest, highest) { return Math.floor((Math.random() * (highest - lowest + 1)) + lowest) };

        var problemNumber = _randomInt(0, self.questionBank.length - 1);
        var problem = self.questionBank[problemNumber];

        var statement = problem.statement;
        var choices = problem.choices;
        var correctAnswer = problem.correct;

        // statement, checkAnswer(answer)  for answerType: numeric
        // statement, choices[0,1,2,3], checkAnswer(answer) for answerType: multiple
        return {
            statement: statement,
            choices: choices,
            checkAnswer: function(answer) { return answer == correctAnswer }
        }
    },

    questionBankMock : [

        {
            statement: 'Which is the odd one out?',
            choices: ['Book','Apple','Orange','Banana'],
            correct: 0
        },
        {
            statement: 'Which is the odd one out?',
            choices: ['Airplane','Apple','Car','Boat'],
            correct: 1
        },
        {
            statement: 'Which is the odd one out?',
            choices: ['Meat','Fish','Orange','Desk'],
            correct: 3
        },
        {
            statement: 'Which is the odd one out?',
            choices: ['Water','Juice','Oil','Brick'],
            correct: 3
        },
        {
            statement: 'Which is the odd one out?',
            choices: ['Bottle','Iron','Wood','Aluminum'],
            correct: 0
        },
        {
            statement: 'Which is the odd one out?',
            choices: ['Teacher','Ball','Policeman','Firefighter'],
            correct: 1
        },
        {
            statement: 'Which is the odd one out?',
            choices: ['Pencil','Pen','Desk','Marker'],
            correct: 2
        },
        {
            statement: 'Which is the odd one out?',
            choices: ['Swim','Run','Sleep','Walk'],
            correct: 2
        },
        {
            statement: 'Which is the odd one out?',
            choices: ['Cat','Dog','Orange','Hamster'],
            correct: 2
        },
        {
            statement: 'Which is the odd one out?',
            choices: ['Book','Happy','Sad','Excited'],
            correct: 0
        },
        {
            statement: 'Which is the odd one out?',
            choices: ['Duck','Feather','Falcon','Penguin'],
            correct: 1
        },
        {
            statement: 'Which is the odd one out?',
            choices: ['Rabbit','Bull','Sheep','Farm'],
            correct: 3
        }
    ]

};
