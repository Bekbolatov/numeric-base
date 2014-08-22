document.numeric.numericTasks['com.sparkydots.numeric.tasks.t.quiz'] =
{
    // follow pattern:
    // parameters: {  param1: {}, param2: {} },  or not set if no params

    // REQUIRED FIELD - follow pattern
    // taskCompletionType is 'fixedNumberOfQuestions' or 'fixedTime'
    taskCompletionType: 'fixedNumberOfQuestions',
    questionType: 'text',
    answerType: 'multiple',

    // REQUIRED FIELD - follow pattern
    // if taskCompletionType is fixedNumberOfQuestions then argument is number of questions answered so far
    // if taskCompletionType is fixedTime then not used
    createNextQuestion: function() {
        var self = this;
        var _randomInt = function (lowest, highest) { return Math.floor((Math.random() * (highest - lowest + 1)) + lowest) };

        var problemNumber = _randomInt(0, self.questionBank.length - 1);
        var problem = self.questionBank[problemNumber];

        var statement = self.questionBankStrings.odd;
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

    // whatever comes below is up to the task writer - this is how info to generate questions is stored
    // ideally you want to compress to some degree to limit the file size
    questionBankStrings: {
        odd: 'Which is the odd one out?'
    },
    questionBank : [

        {
            choices: ['Book','Apple','Orange','Banana'],
            correct: 0
        },
        {
            choices: ['Airplane','Apple','Car','Boat'],
            correct: 1
        },
        {
            choices: ['Meat','Fish','Orange','Desk'],
            correct: 3
        },
        {
            choices: ['Water','Juice','Oil','Brick'],
            correct: 3
        },
        {
            choices: ['Bottle','Iron','Wood','Aluminum'],
            correct: 0
        },
        {
            choices: ['Teacher','Ball','Policeman','Firefighter'],
            correct: 1
        },
        {
            choices: ['Pencil','Pen','Desk','Marker'],
            correct: 2
        },
        {
            choices: ['Swim','Run','Sleep','Walk'],
            correct: 2
        },
        {
            choices: ['Cat','Dog','Orange','Hamster'],
            correct: 2
        },
        {
            choices: ['Book','Happy','Sad','Excited'],
            correct: 0
        },
        {
            choices: ['Duck','Feather','Falcon','Penguin'],
            correct: 1
        },
        {
            choices: ['Rabbit','Bull','Sheep','Farm'],
            correct: 3
        }
    ]

};
