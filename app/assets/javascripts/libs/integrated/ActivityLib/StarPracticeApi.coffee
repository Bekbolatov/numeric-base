angular.module('ActivityLib')

.factory "StarPracticeApi", ['DataPack', 'DataUtilities', 'RandomFunctions', 'TextFunctions', 'MathFunctions', 'HyperTextManager', 'GraphicsManager', (DataPack, DataUtilities, RandomFunctions, TextFunctions, MathFunctions, HyperTextManager, GraphicsManager ) ->
    class StarPracticeApi
        constructor: () ->

            @DataPack = DataPack
            @DataUtilities = DataUtilities

            @RandomFunctions = RandomFunctions
            @TextFunctions = TextFunctions
            @MathFunctions = MathFunctions

            @HyperTextManager = HyperTextManager
            @GraphicsManager = GraphicsManager

    starPracticeApi = new StarPracticeApi()
    document.numeric.modules.StarPracticeApi = starPracticeApi
    starPracticeApi
    ]