angular.module('Krista')

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
                ]
                bird: [
                    [ [ ['red bird', 'red birds'], [ 'blue bird', 'blue birds'] ], ['bird', 'birds'] ]
                    [ [ ['robin', 'robins'], [ 'sparrow', 'sparrows'] ] ]
                ]
                zoo: [
                    [ [ ['penguin', 'penguins'], [ 'meerkat', 'meerkats'] ] ]
                    [ [ ['zebra', 'zebras'], [ 'deer', 'deers'] ] ]
                ]
                forest: [
                    [ [ ['wolf', 'wolves'], [ 'rabbit', 'rabbits'] ] ]
                    [ [ ['pine tree', 'pine trees'], [ 'cedar tree', 'cedar trees'] ], ['cedar or pine tree',  'cedar and pine trees'] ]
                    [ [ ['bear', 'bears'], [ 'squirrel', 'squirrels'] ] ]
                ]
                animal: [
                    [ [ ['red bird', 'red birds'], [ 'blue bird', 'blue birds'] ], ['bird', 'birds'] ]
                    [ [ ['dog', 'dogs'], [ 'cat', 'cats'] ], ['animal', 'animals'] ]
                    [ [ ['mouse', 'mice'], [ 'cat', 'cats'] ] ]
                ]
                barn: [
                    [ [ ['dog', 'dogs'], [ 'cat', 'cats'] ], ['animal', 'animals'] ]
                    [ [ ['horse', 'horses'], [ 'cow', 'cows'] ] ]
                    [ [ ['pig', 'pigs'], [ 'cow', 'cows'] ] ]
                    [ [ ['duck', 'ducks'], [ 'chicken', 'chickens'] ] ]
                ]
                thing: [
                    [ [ ['orange candy', 'orange candies'], [ 'green candy', 'green candies'] ], ['candy', 'candies'] ]
                    [ [ ['red ball', 'red balls'], [ 'green ball', 'green balls'] ], ['ball', 'balls'] ]
                    [ [ ['red marble', 'red marbles'], [ 'blue marble', 'blue marbles'] ], ['marble', 'marbles'] ]
                    [ [ ['black pencil', 'black pencils'], [ 'red pencil', 'red pencils'] ], ['pencil', 'pencils'] ]
                    [ [ ['pencil', 'pencils'], [ 'pen', 'pens'] ] ]
                    [ [ ['dime', 'dimes'], [ 'quarter', 'quarters'] ], [ 'coin', 'coins' ] ]
                    [ [ ['apple', 'apples'], [ 'banana', 'bananas'] ] ]
                    [ [ ['fruit', 'fruits'], [ 'vegetable', 'vegetables'] ] ]
                    [ [ ['pea', 'peas'], [ 'carrot', 'carrots'] ] ]
                ]
            }
            location : {
                person: [
                    [ [''], '' ]
                    [ [''], '' ]
                    [ ['room'], 'in the' ]
                    [ ['class', 'ballet class'], 'in the' ]
                    [ ['classroom'], 'in the' ]
                    [ ['building'], 'in the' ]
                    [ ['lobby'], 'in the' ]
                    [ ['hotel'], 'in the' ]
                    [ ['park'], 'in the' ]
                    [ ['museum'], 'in the' ]
                    [ ['train station'], 'at the' ]
                    [ ['playground'], 'on the' ]
                    [ ['school'], 'in the' ]
                ]
                bird: [
                    [ [''], '' ]
                    [ [''], '' ]
                    [ ['tree', 'tall'], 'on the', 'sitting' ]
                    [ ['park'], 'in the' ]
                    [ ['forest'], 'in the' ]
                    [ ['lake'], 'by the', 'sitting' ]
                ]
                zoo: [
                    [ [''], '' ]
                    [ [''], '' ]
                    [ ['zoo', 'local'], 'at the' ]
                ]
                forest: [
                    [ [''], '' ]
                    [ [''], '' ]
                    [ ['forest'], 'in the' ]
                ]
                animal: [
                    [ [''], '' ]
                    [ [''], '' ]
                    [ [''], '' ]
                    [ ['city', 'small'], 'in the' ]
                ]
                barn: [
                    [ [''], '' ]
                    [ [''], '' ]
                    [ ['yard'], 'on the' ]
                    [ ['barn'], 'in the' ]
                ]
                thing: [
                    [ [''], '' ]
                    [ [''], '' ]
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
