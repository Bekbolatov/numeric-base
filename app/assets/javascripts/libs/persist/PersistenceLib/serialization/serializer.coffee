angular.module 'ModulePersistence'

.factory 'SerializationMethods', [ () ->
    class SerializationMethods
        serialize: (object) -> JSON.stringify(object)
        deserialize: (textData) -> JSON.parse(textData)

    new SerializationMethods()
]

