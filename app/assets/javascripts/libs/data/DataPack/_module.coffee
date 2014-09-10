angular.module 'ModuleDataPack', []

angular.module 'ModuleDataPack'

.factory 'DataPack', [() ->
    class DataPack
        data: {
            name: {
                male: [ 'Jackson', 'Aiden', 'Liam', 'Lucas', 'Noah', 'Jayden', 'Ethan', 'Jacob', 'Jack', 'Logan', 'Benjamin', 'Michael', 'Ryan', 'Alexander', 'Elijah',
                    'James', 'William', 'Oliver', 'Connor', 'Matthew', 'Daniel', 'Luke', 'Henry', 'Gabriel', 'Joshua', 'Nicholas', 'Isaac', 'Nathan', 'Andrew', 'Samuel',
                    'Christian', 'Evan', 'Charlie', 'David', 'Sebastian', 'Joseph', 'Anthony', 'John', 'Tyler', 'Zachary', 'Thomas', 'Julian', 'Adam', 'Isaiah', 'Alex', 'Aaron',
                    'Parker', 'Cooper', 'Miles', 'Chase', 'Christopher', 'Blake', 'Austin', 'Jordan', 'Leo', 'Jonathan', 'Adrian', 'Colin', 'Hudson', 'Ian', 'Xavier', 'Tristan',
                    'Jason', 'Brody', 'Nathaniel', 'Jake', 'Jeremiah', 'Elliot', 'Derek', 'Toby']
                female: [ 'Sally', 'Lynn', 'Sophia', 'Emma', 'Olivia', 'Isabella', 'Mia', 'Ava', 'Lily', 'Zoe', 'Emily', 'Chloe', 'Layla', 'Madison', 'Madelyn', 'Abigail', 'Aubrey', 'Charlotte', 'Amelia',
                    'Ella', 'Kaylee', 'Avery', 'Aaliyah', 'Hailey', 'Hannah', 'Aria', 'Arianna', 'Lila', 'Evelyn', 'Grace', 'Ellie', 'Anna', 'Kaitlyn', 'Isabelle', 'Sophie', 'Scarlett',
                    'Natalie', 'Leah', 'Sarah', 'Nora', 'Mila', 'Elizabeth', 'Lillian', 'Kylie', 'Audrey', 'Lucy', 'Maya', 'Annabelle', 'Gabriella', 'Elena', 'Victoria', 'Claire', 'Savannah',
                    'Maria', 'Stella', 'Liliana', 'Allison', 'Samantha', 'Alyssa', 'Molly', 'Violet', 'Julia', 'Eva', 'Alice', 'Alexis', 'Kayla', 'Katherine', 'Lauren', 'Jasmine', 'Caroline', 'Vivian', 'Juliana']
            }
            buyable: ['a magazine', 'a new toy robot', 'a new diary', 'a book', 'a book about birds', 'a movie ticket']

            itemsWithPrices: [
                [
                    ['types of pets', 'pet', 'prices', 'price', ['$', ''] ]
                    [
                        ['Goldfish', 10]
                        ['Kitten', 35]
                        ['Puppy', 40]
                        ['Ferret', 30]
                        ['Iguana', 70]
                        ['Parrot', 50]
                        ['Parakeet', 20]
                        ['Snake', 20]
                        ['Turtle', 30]
                        ['Frog', 10]
                    ]
                ]
                [
                    ['types of fish', 'fish', 'prices', 'price', ['$', ''] ]
                    [
                        ['Acei Cichlid', 10]
                        ['African Cichlid', 10]
                        ['African Featherfin Catfish', 20]
                        ['African Knifefish', 10]
                        ['Albino Cory Catfish', 5 ]
                        ['Algae Eater', 5]
                        ['Angelfish', 10]
                        ['Angelicus Botia', 15]
                        ['Auratus Cichlid', 10]
                        ['Australian Rainbowfish', 5]
                        ['Black Ghost Knifefish', 15]
                        ['Black Moor Goldfish', 10]
                        ['Boesemani Rainbowfish', 10]
                        ['Peacock Eel', 15]
                        ['Fancy Goldfish', 35]
                        ['Pigeon Blood Discus', 400]
                        ['Calico Ryukin Goldfish', 200 ]
                        ['Elongated Mbuna', 80]
                        ['Neon Tetra', 60]
                        ['Serpae Tetra', 65]
                        ['Snow White Socolofi', 75]
                        ['Orange Sailfin Molly', 45]
                        ['Red Sailfin Molly', 45]
                        ['Red Swordtail', 40]
                        ['Green Tiger Barb', 30]
                        ['Plakat Betta', 40]
                    ]
                ]
                [
                    ['cars', 'car', 'maximum speeds', 'maximum speed', ['', ' mph'] ]
                    [
                        ['Nissan Centra', 120]
                        ['Toyota Camry', 130]
                        ['Honda Odyssey', 160]
                        ['Dodge Caravan', 150]
                        ['Dodge Caravan', 150]
                        ['Mazda 626', 175]
                        ['Mazda Protege', 165]
                        ['Ford Mustang', 170]
                        ['Cadillac', 160]
                        ['Hummer H2', 120]
                        ['Toyota Prius', 110]
                        ['Tesla Model S', 145]
                        ['Mercedes-Benz SLK', 140]
                        ['BMW i3', 170]
                        ['Subaru Outback', 135]
                        ['Subaru Tribeca', 145]
                        ['BMW x5', 150]
                        ['Volkswagen Jetta', 160]
                    ]
                ]
                [
                    ['types of boats', 'boat', 'lengths', 'length', ['', ' ft'] ]
                    [
                        ['Class A small', 5]
                        ['Class A medium', 10]
                        ['Class A large', 15]
                        ['Class 1 medium', 20]
                        ['Class 1 large', 25]
                        ['Class 2 medium', 30]
                        ['Class 2 large', 35]
                        ['Class 3 small', 40]
                        ['Class 3 medium', 50]
                        ['Class 3 large', 60]
                    ]
                ]

            ]

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

    dataPack = new DataPack()
    document.numeric.modules.DataPack = dataPack

    dataPack
]