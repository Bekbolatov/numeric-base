angular.module 'ImageLib'

.factory 'ImageData', [() ->
    class ImageData
        constructor: ->
            @colors =
                0:
                    'B': String.fromCharCode(0, 0, 0, 0)
                    'D': String.fromCharCode(50, 50, 50, 0)
                    'G': String.fromCharCode(150, 150, 150, 0)
                    'L': String.fromCharCode(210, 210, 210, 0)
                    'w': String.fromCharCode(255, 255, 255, 0)
                    'r': String.fromCharCode(255, 0, 0, 0)
                    'g': String.fromCharCode(0, 255, 0, 0)
                    'b': String.fromCharCode(0, 0, 255, 0)
            @chars =
                0:
                    '0': [5, 7, [0,1,1,1,0, 1,0,0,0,1, 1,0,0,0,1, 1,0,0,0,1, 1,0,0,0,1, 1,0,0,0,1, 0,1,1,1,0 ]]
                    '1': [5, 7, [0,0,1,0,0, 0,1,1,0,0, 0,0,1,0,0, 0,0,1,0,0, 0,0,1,0,0, 0,0,1,0,0, 1,1,1,1,1 ]]
                    '2': [5, 7, [0,1,1,1,0, 1,0,0,0,1, 0,0,0,0,1, 0,0,0,1,0, 0,0,1,0,0, 0,1,0,0,0, 1,1,1,1,1 ]]
                    '3': [5, 7, [1,1,1,1,1, 0,0,0,1,0, 0,0,1,0,0, 0,0,0,1,0, 0,0,0,0,1, 1,0,0,0,1, 0,1,1,1,0 ]]
                    '4': [5, 7, [0,0,0,1,0, 0,0,1,1,0, 0,1,0,1,0, 1,0,0,1,0, 1,1,1,1,1, 0,0,0,1,0, 0,0,0,1,0 ]]
                    '5': [5, 7, [1,1,1,1,1, 1,0,0,0,0, 1,1,1,1,0, 0,0,0,0,1, 0,0,0,0,1, 0,0,0,0,1, 1,1,1,1,0 ]]
                    '6': [5, 7, [0,0,1,1,0, 0,1,0,0,0, 1,0,0,0,0, 1,1,1,1,0, 1,0,0,0,1, 1,0,0,0,1, 0,1,1,1,0 ]]
                    '7': [5, 7, [1,1,1,1,1, 0,0,0,0,1, 0,0,0,1,0, 0,0,1,0,0, 0,1,0,0,0, 0,1,0,0,0, 0,1,0,0,0 ]]
                    '8': [5, 7, [0,1,1,1,0, 1,0,0,0,1, 1,0,0,0,1, 0,1,1,1,0, 1,0,0,0,1, 1,0,0,0,1, 0,1,1,1,0 ]]
                    '9': [5, 7, [0,1,1,1,0, 1,0,0,0,1, 1,0,0,0,1, 0,1,1,1,1, 0,0,0,0,1, 0,0,0,1,0, 0,1,1,0,0 ]]
                    '?': [5, 7, [0,1,1,1,0, 1,0,0,0,1, 0,0,0,0,1, 0,0,0,1,0, 0,0,1,0,0, 0,0,0,0,0, 0,0,1,0,0 ]]
                    '-': [5, 7, [0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,1,1,1,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0 ]]
                    '.': [5, 7, [0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,1,1,0,0, 0,1,1,0,0 ]]
                    'A': [5, 7, [0,1,1,1,0, 1,0,0,0,1, 1,0,0,0,1, 1,0,0,0,1, 1,1,1,1,1, 1,0,0,0,1, 1,0,0,0,1 ]]
                    'B': [5, 7, [1,1,1,1,0, 1,0,0,0,1, 1,0,0,0,1, 1,1,1,1,0, 1,0,0,0,1, 1,0,0,0,1, 1,1,1,1,0 ]]
                    'C': [5, 7, [0,1,1,1,0, 1,0,0,0,1, 1,0,0,0,0, 1,0,0,0,0, 1,0,0,0,0, 1,0,0,0,1, 0,1,1,1,0 ]]
                    'D': [5, 7, [1,1,1,0,0, 1,0,0,1,0, 1,0,0,0,1, 1,0,0,0,1, 1,0,0,0,1, 1,0,0,1,0, 1,1,1,0,0 ]]
                    'E': [5, 7, [1,1,1,1,1, 1,0,0,0,0, 1,0,0,0,0, 1,1,1,1,0, 1,0,0,0,0, 1,0,0,0,0, 1,1,1,1,1 ]]
                    'F': [5, 7, [1,1,1,1,1, 1,0,0,0,0, 1,0,0,0,0, 1,1,1,1,0, 1,0,0,0,0, 1,0,0,0,0, 1,0,0,0,0 ]]
                    'G': [5, 7, [0,1,1,1,0, 1,0,0,0,1, 1,0,0,0,0, 1,0,1,1,1, 1,0,0,0,1, 1,0,0,0,1, 0,1,1,1,1 ]]
                    'H': [5, 7, [1,0,0,0,1, 1,0,0,0,1, 1,0,0,0,1, 1,1,1,1,1, 1,0,0,0,1, 1,0,0,0,1, 1,0,0,0,1 ]]
                    'I': [5, 7, [1,1,1,1,1, 0,0,1,0,0, 0,0,1,0,0, 0,0,1,0,0, 0,0,1,0,0, 0,0,1,0,0, 1,1,1,1,1 ]]
                    'J': [5, 7, [0,0,1,1,1, 0,0,0,1,0, 0,0,0,1,0, 0,0,0,1,0, 0,0,0,1,0, 1,0,0,1,0, 0,1,1,0,0 ]]
                    'K': [5, 7, [1,0,0,0,1, 1,0,0,1,0, 1,0,1,0,0, 1,1,0,0,0, 1,0,1,0,0, 1,0,0,1,0, 1,0,0,0,1 ]]
                    'L': [5, 7, [1,0,0,0,0, 1,0,0,0,0, 1,0,0,0,0, 1,0,0,0,0, 1,0,0,0,0, 1,0,0,0,0, 1,1,1,1,1 ]]
                    'M': [5, 7, [1,0,0,0,1, 1,1,0,1,1, 1,0,1,0,1, 1,0,1,0,1, 1,0,0,0,1, 1,0,0,0,1, 1,0,0,0,1 ]]
                    'N': [5, 7, [1,0,0,0,1, 1,0,0,0,1, 1,1,0,0,1, 1,0,1,0,1, 1,0,0,1,1, 1,0,0,0,1, 1,0,0,0,1 ]]
                    'O': [5, 7, [0,1,1,1,0, 1,0,0,0,1, 1,0,0,0,1, 1,0,0,0,1, 1,0,0,0,1, 1,0,0,0,1, 0,1,1,1,0 ]]
                    'P': [5, 7, [1,1,1,1,0, 1,0,0,0,1, 1,0,0,0,1, 1,1,1,1,0, 1,0,0,0,0, 1,0,0,0,0, 1,0,0,0,0 ]]
                    'Q': [5, 7, [0,1,1,1,0, 1,0,0,0,1, 1,0,0,0,1, 1,0,0,0,1, 1,0,1,0,1, 1,0,0,1,0, 0,1,1,0,1 ]]
                    'R': [5, 7, [1,1,1,1,0, 1,0,0,0,1, 1,0,0,0,1, 1,1,1,1,0, 1,0,1,0,0, 1,0,0,1,0, 1,0,0,0,1 ]]
                    'S': [5, 7, [0,1,1,1,1, 1,0,0,0,0, 1,0,0,0,0, 0,1,1,1,0, 0,0,0,0,1, 0,0,0,0,1, 1,1,1,1,0 ]]
                    'T': [5, 7, [1,1,1,1,1, 0,0,1,0,0, 0,0,1,0,0, 0,0,1,0,0, 0,0,1,0,0, 0,0,1,0,0, 0,0,1,0,0 ]]
                    'U': [5, 7, [1,0,0,0,1, 1,0,0,0,1, 1,0,0,0,1, 1,0,0,0,1, 1,0,0,0,1, 1,0,0,0,1, 0,1,1,1,0 ]]
                    'V': [5, 7, [1,0,0,0,1, 1,0,0,0,1, 1,0,0,0,1, 1,0,0,0,1, 1,0,0,0,1, 0,1,0,1,0, 0,0,1,0,0 ]]
                    'W': [5, 7, [1,0,0,0,1, 1,0,0,0,1, 1,0,0,0,1, 1,0,1,0,1, 1,0,1,0,1, 1,0,1,0,1, 0,1,0,1,0 ]]
                    'X': [5, 7, [1,0,0,0,1, 1,0,0,0,1, 0,1,0,1,0, 0,0,1,0,0, 0,1,0,1,0, 1,0,0,0,1, 1,0,0,0,1 ]]
                    'Y': [5, 7, [1,0,0,0,1, 1,0,0,0,1, 1,0,0,0,1, 0,1,0,1,0, 0,0,1,0,0, 0,0,1,0,0, 0,0,1,0,0 ]]
                    'Z': [5, 7, [1,1,1,1,1, 0,0,0,0,1, 0,0,0,1,0, 0,0,1,0,0, 0,1,0,0,0, 1,0,0,0,0, 1,1,1,1,1 ]]
                    'a': [5, 7, [ ]]
                    'b': [5, 7, [ ]]
                    'c': [5, 7, [ ]]
                    'd': [5, 7, [ ]]
                    'e': [5, 7, [ ]]
                    'f': [5, 7, [ ]]
                    'g': [5, 7, [ ]]
                    'h': [5, 7, [ ]]
                    'i': [5, 7, [ ]]
                    'j': [5, 7, [ ]]
                    'k': [5, 7, [ ]]
                    'l': [5, 7, [ ]]
                    'm': [5, 7, [ ]]
                    'n': [5, 7, [ ]]
                    'o': [5, 7, [ ]]
                    'p': [5, 7, [ ]]
                    'q': [5, 7, [ ]]
                    'r': [5, 7, [ ]]
                    's': [5, 7, [ ]]
                    't': [5, 7, [ ]]
                    'u': [5, 7, [ ]]
                    'v': [5, 7, [ ]]
                    'w': [5, 7, [ ]]
                    'x': [5, 7, [ ]]
                    'y': [5, 7, [ ]]
                    'z': [5, 7, [ ]]
