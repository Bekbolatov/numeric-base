angular.module('Krista')

.factory "M15", ['KristaData', 'KristaUtil', (KristaData, KristaUtil ) ->
    class M15
        u: KristaUtil
        generate: ->

            itemsList = [
                [
                    ['types of pets', 'pet', 'prices', 'price', [true, '$'] ]
                    [
                        ['Goldfish', 10]
                        ['Kitten', 10]
                        ['Ferret', 10]
                        ['Iguana', 10]
                        ['Ferret', 10]
                    ]
                ]
                [
                    ['types of fish', 'pet', 'prices', 'price', [true, '$'] ]
                    [
                        ['Goldfish', 10]
                        ['Kitten', 10]
                        ['Ferret', 10]
                        ['Iguana', 10]
                    ]
                ]
                [
                    ['toy car models', 'model', 'prices', 'price', [true, '$'] ]
                    [
                        ['Goldfish', 10]
                        ['Kitten', 10]
                        ['Ferret', 10]
                        ['Iguana', 10]
                    ]
                ]
                [
                    ['cars', 'car', 'speeds', 'speed', [false, ' mph'] ]
                    [
                        ['Mustang', 10]
                        ['Kitten', 10]
                        ['Ferret', 10]
                        ['Iguana', 10]
                    ]
                ]
                [
                    ['boats', 'boat', 'lengths', 'length', [false, ' ft'] ]
                    [
                        ['Boat1', 10]
                        ['Boat2', 20]
                        ['Boat3', 30]
                        ['Boat4', 40]
                        ['Boat5', 50]
                        ['Boat6', 60]
                        ['Boat7', 70]
                    ]
                ]

            ]

            items = @u.randomFromList(itemsList)
            types = items[0][0]
            type = items[0][1]
            prices = items[0][2]
            price = items[0][3]
            convertPrice = (p) ->
                if items[0][4][0]
                    items[0][4][1] + p
                else
                    '' + p + ' ' + items[0][4][1]
            picked = @u.randomNonRepeating(items[1], 4)

            answers = [ 2,3,4,5,6]
            index = 1

            table = @u.toTable(
                ( [ pick[0], convertPrice(pick[1]) ] for pick in picked)
                [ @u.capitalize(type),  @u.capitalize(price) ]
            )
            console.log(table)
            [  [ 'The table below shows the ' + prices + ' for 4 ' + type + '. What was the average ' + price + '? <span class="problem-generated-problem-holder">' + table + '</span' , answers ], index]

    new M15()
]