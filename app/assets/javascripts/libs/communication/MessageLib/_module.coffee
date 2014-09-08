angular.module 'ModuleMessage', ['ModulePersistence']

angular.module 'ModuleMessage'
.factory "MessageDispatcher", ['PersistenceManager', ( PersistenceManager )  ->
    class MessageDispatcher
        constructor: () ->
            @MAXSEENMSG = 20
            @persister = PersistenceManager.localStoreBlockingDictionaryPersister(document.numeric.key.messages)
            init = @persister.init()
            if init == null
                @addNewMessage({id: 1, priority: 5, content: 'Pick an activity that you want to practice'})
        cmp: (s) ->
            (a, b) ->
                if a[0] > b[0]
                    1 * s
                else
                    -1 * s
        addNewMessages: (msgs) ->
            try
                for msg in msgs
                    @addNewMessage(msg)
            catch t
                console.log('could not add messages from server')
        addNewMessage: (msg) ->
            try
                if msg == undefined || msg.content == undefined || msg.id == undefined || msg.priority == undefined
                    return undefined
                id = Number(msg.id)
                priority = Number(msg.priority)
                if isNaN(id) || isNaN(priority)
                    return undefined

                prev = @persister.get(msg.id)
                if prev == undefined
                    msg.seen = false
                    msg.id = id
                    msg.priority = priority
                    msg.rcvdTime = (new Date()).getTime()
                    @persister.set(msg.id, msg)
            catch t
                console.log('could not add new message')
        markAsSeen: (msg) ->
            msg = @persister.get(msg.id)
            msg.seen = true
            @persister.set(msg.id, msg)
        removeMessage: (msg) ->
            @persister.remove(msg.id)
        removeOneSeenMessageIfCloseToMax: (all) ->
            try
                if all.length > @MAXSEENMSG
                    seen = ( [msg.rcvdTime, msg] for id, msg of all when msg.seen)
                    if seen.length < 1
                        return undefined
                    seen.sort(@cmp(1))
                    msg = seen[0][1]
                    @removeMessage(msg)
            catch t
                return undefined
        getMessageToShow: () ->
            try
                all = @persister.getAll()
                if all == undefined || all.length < 1
                    return undefined
                @removeOneSeenMessageIfCloseToMax(all)
                unseen = ( [msg.priority, msg] for id, msg of all when !msg.seen)
                if unseen.length < 1
                    return undefined
                unseen.sort(@cmp(-1))
                msg = unseen[0][1]
                @markAsSeen(msg)
                msg
            catch t
                return undefined


    new MessageDispatcher()
]

