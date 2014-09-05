angular.module 'BaseLib'

.factory "MathFunctions", [ ->
    class MathFunctions
        gcd: (a, b) ->
            if a < 0
                a = -a
            if b < 0
                b = -b
            if a > b
                [a, b] = [b, a]
            if a == 0
                b
            if b == 0
                a

            c = b - Math.floor(b/a) * a
            if c <= 0
                a
            else
                @gcd(c, a)

        reduce: (a, b) ->
            c = @gcd(a, b)
            [a/c, b/c]

    mathFunctions = new MathFunctions()
    document.numeric.modules.MathFunctions = mathFunctions
    mathFunctions
]
