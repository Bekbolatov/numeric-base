angular.module 'ModuleDataUtilities', ['ModuleDataPack', 'BaseLib']

angular.module 'ModuleDataUtilities'

.factory 'DataUtilities', ['DataPack', 'RandomFunctions', (DataPack, RandomFunctions ) ->
    class DataUtilities
        d: DataPack
        r: RandomFunctions
        randomName: () =>
            names = @d.data.name
            l1 = names.male.length
            l2 = names.female.length
            n1 = @r.random(0, l1 + l2)
            if n1 >= l1
                name = [names.female[n1-l1], 'she', 'her', 'her']
            else
                name = [names.male[n1], 'he', 'him', 'his']
            name
        randomNames: (n, filter) ->
            o = []
            names = []
            f = (n) -> ( ( filter == undefined ) || filter(n) )
            for i in [ 1 .. n ]
                name = @randomName()
                while ( (o.indexOf(name[0]) > -1) || ( !f(name[0]) ) )
                    name = @randomName()
                o.push(name[0])
                names.push(name)
            names

    dataUtilities = new DataUtilities()
    document.numeric.modules.DataUtilities = dataUtilities
    dataUtilities

]