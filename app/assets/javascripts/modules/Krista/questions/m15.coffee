angular.module('Krista')

.factory "M15", ['DataPack', 'RandomFunctions', 'HyperTextManager','TextFunctions', (DataPack, RandomFunctions, HyperTextManager, TextFunctions ) ->
    class M15
        u: RandomFunctions
        d: DataPack
        h: HyperTextManager
        t: TextFunctions
        generate: ->
            items = @u.randomFromList(@d.data.itemsWithPrices)

            types = items[0][0]
            type = items[0][1]
            prices = items[0][2]
            price = items[0][3]
            convertPrice = (p) -> items[0][4][0] + p + ' ' + items[0][4][1]

            pickedIndices = @u.randomNonRepeating([ 0 .. (items[1].length - 1) ], 4)
            picked = ( items[1][i] for i in pickedIndices )

            correct =  ( picked.reduce (  (x,y) -> [1, x[1] + y[1]] ) )[1] / 4

            inc = [
                correct + @u.randomFromList([ -1.50, -1.25, 1.25, 1.50])
                correct + @u.randomFromList([ -3, -2, 2, 3])
                correct + @u.randomFromList([ -4.50, -4, 4, 4.50])
                correct + @u.randomFromList([ -10, -9, -8, -7, -6, -5, 5, 6, 7, 8, 9, 10])
            ]

            [answers, index] = @u.shuffleAnswers4(inc, correct)

            table = @h.tableWrapped(
                ( [ pick[0], convertPrice(pick[1]) ] for pick in picked)
                [ @t.capitalize(type),  @t.capitalize(price) ]
            )

            [  [ 'The table below shows the ' + prices + ' for 4 ' + types + '. What is the average ' + price + '? <br>' + table  , answers ], index]

    new M15()
]