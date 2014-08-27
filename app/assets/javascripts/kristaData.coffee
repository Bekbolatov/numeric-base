angular.module('AppOne')

.factory "KristaData", [ () ->
    class KristaData
        data: {
            name: {
                male: [ 'Jackson', 'Aiden', 'Liam', 'Lucas', 'Noah', 'Jayden', 'Ethan', 'Jacob', 'Jack', 'Logan', 'Benjamin', 'Michael', 'Ryan', 'Alexander', 'Elijah',
                    'James', 'William', 'Oliver', 'Connor', 'Matthew', 'Daniel', 'Luke', 'Henry', 'Gabriel', 'Joshua', 'Nicholas', 'Isaac', 'Nathan', 'Andrew', 'Samuel',
                    'Christian', 'Evan', 'Charlie', 'David', 'Sebastian', 'Joseph', 'Anthony', 'John', 'Tyler', 'Zachary', 'Thomas', 'Julian', 'Adam', 'Isaiah', 'Alex', 'Aaron',
                    'Parker', 'Cooper', 'Miles', 'Chase', 'Christopher', 'Blake', 'Austin', 'Jordan', 'Leo', 'Jonathan', 'Adrian', 'Colin', 'Hudson', 'Ian', 'Xavier', 'Tristan',
                    'Jason', 'Brody', 'Nathaniel', 'Jake', 'Jeremiah', 'Elliot']
                female: [ 'Sally', 'Lynn', 'Sophia', 'Emma', 'Olivia', 'Isabella', 'Mia', 'Ava', 'Lily', 'Zoe', 'Emily', 'Chloe', 'Layla', 'Madison', 'Madelyn', 'Abigail', 'Aubrey', 'Charlotte', 'Amelia',
                    'Ella', 'Kaylee', 'Avery', 'Aaliyah', 'Hailey', 'Hannah', 'Aria', 'Arianna', 'Lila', 'Evelyn', 'Grace', 'Ellie', 'Anna', 'Kaitlyn', 'Isabelle', 'Sophie', 'Scarlett',
                    'Natalie', 'Leah', 'Sarah', 'Nora', 'Mila', 'Elizabeth', 'Lillian', 'Kylie', 'Audrey', 'Lucy', 'Maya', 'Annabelle', 'Gabriella', 'Elena', 'Victoria', 'Claire', 'Savannah',
                    'Maria', 'Stella', 'Liliana', 'Allison', 'Samantha', 'Alyssa', 'Molly', 'Violet', 'Julia', 'Eva', 'Alice', 'Alexis', 'Kayla', 'Katherine', 'Lauren', 'Jasmine', 'Caroline', 'Vivian', 'Juliana']
            }
            item: {
                person: [
                    [ [ ['boy', 'boys'], [ 'girl', 'girls'] ], ['kid', 'children'] ]
                    [ [ ['boy', 'boys'], [ 'girl', 'girls'] ], ['kid', 'children'] ]
                    [ [ ['adult', 'adults'], [ 'kid', 'kids'] ], ['person', 'people'] ]
                    [ [ ['man', 'men'], [ 'woman', 'women'] ], ['person', 'people'] ]
                    [ [ ['firefighter', 'firefighters'], [ 'police man', 'police men'] ], ['firefighter or police man', 'firefighters and police men together'] ]
                ]
                bird: [
                    [ [ ['red bird', 'red birds'], [ 'blue bird', 'blue birds'] ], ['bird', 'birds'] ]
                    [ [ ['robin', 'robins'], [ 'sparrow', 'sparrows'] ], ['robin or sparrow', 'robins and sparrows together'] ]
                ]
                zoo: [
                    [ [ ['penguin', 'penguins'], [ 'meerkat', 'meerkats'] ], ['penguin or meerkat', 'penguins and meerkats together'] ]
                    [ [ ['zebra', 'zebras'], [ 'deer', 'deers'] ], ['zebra or deer', 'zebras and deers together'] ]
                ]
                forest: [
                    [ [ ['wolf', 'wolves'], [ 'rabbit', 'rabbits'] ], ['wolf or rabbit',  'wolves and rabbits together'] ]
                    [ [ ['pine tree', 'pine trees'], [ 'cedar tree', 'cedar trees'] ], ['cedar or pine tree',  'cedar and pine trees'] ]
                    [ [ ['bear', 'bears'], [ 'squirrel', 'squirrels'] ], ['bear or squirrel',  'bears and squirrels together'] ]
                ]
                animal: [
                    [ [ ['red bird', 'red birds'], [ 'blue bird', 'blue birds'] ], ['bird', 'birds'] ]
                    [ [ ['dog', 'dogs'], [ 'cat', 'cats'] ], ['animal', 'animals'] ]
                    [ [ ['mouse', 'mice'], [ 'cat', 'cats'] ], ['mouse or cat', 'mice and cats together'] ]
                    [ [ ['horse', 'horses'], [ 'cow', 'cows'] ], ['horse or cow', 'horses and cows together'] ]
                ]
                thing: [
                    [ [ ['orange candy', 'orange candies'], [ 'green candy', 'green candies'] ], ['candy', 'candies'] ]
                    [ [ ['red ball', 'red balls'], [ 'green ball', 'green balls'] ], ['ball', 'balls'] ]
                    [ [ ['red marble', 'red marbles'], [ 'blue marble', 'blue marbles'] ], ['marble', 'marbles'] ]
                    [ [ ['pencil', 'pencils'], [ 'pen', 'pens'] ], ['pen or pencil', 'pens and pencils together'] ]
                    [ [ ['black pencil', 'black pencils'], [ 'red pencil', 'red pencils'] ], ['pencil', 'pencils'] ]
                    [ [ ['apple', 'apples'], [ 'banana', 'bananas'] ], ['apple or banana', 'apples and bananas together'] ]
                    [ [ ['fruit', 'fruits'], [ 'vegetable', 'vegetables'] ], ['fruit or vegetable', 'fruits and vegetables together'] ]
                    [ [ ['book about computers', 'books about computers'], [ 'book about food', 'books about food'] ], ['book', 'books'] ]
                    [ [ ['pea', 'peas'], [ 'carrot', 'carrots'] ], ['pea or carrot', 'peas and carrots together'] ]
                ]
            }
            location : {
                person: [
                    [ [''], '' ]
                    [ ['picture'], 'on the' ]
                    [ ['room'], 'in the' ]
                    [ ['class', 'ballet class'], 'in the' ]
                    [ ['class'], 'in the' ]
                    [ ['building'], 'in the' ]
                    [ ['lobby'], 'in the' ]
                    [ ['hotel'], 'in the' ]
                    [ ['park'], 'in the' ]
                    [ ['museum'], 'in the' ]
                    [ ['bank'], 'in the' ]
                    [ ['train station'], 'at the' ]
                    [ ['playground'], 'on the' ]
                    [ ['school'], 'in the' ]
                ]
                bird: [
                    [ [''], '' ]
                    [ ['picture'], 'on the' ]
                    [ ['tree', 'tall'], 'on the', 'sitting' ]
                    [ ['park'], 'in the' ]
                    [ ['forest'], 'in the' ]
                    [ ['lake'], 'by the', 'sitting' ]
                ]
                zoo: [
                    [ [''], '' ]
                    [ ['picture'], 'on the' ]
                    [ ['zoo', 'local'], 'at the' ]
                ]
                forest: [
                    [ [''], '' ]
                    [ ['picture'], 'on the' ]
                    [ ['forest'], 'in the' ]
                ]
                animal: [
                    [ [''], '' ]
                    [ ['picture'], 'on the' ]
                    [ ['city'], 'in the' ]
                ]
                thing: [
                    [ [''], '' ]
                    [ ['picture'], 'on the' ]
                    [ ['city'], 'in the' ]
                    [ ['room'], 'in the' ]
                    [ ['box'], 'in the' ]
                    [ ['table'], 'on the' ]
                    [ ['room'], 'in the' ]
                ]
            }
        }

    console.log('KristaData factory')
    new KristaData()
]
