angular.module('filters', [])

.filter 'questionMark', ->
    (input) ->
        if input == undefined
            '?'
        else
            input

.filter 'firstCapital', ->
    (input) ->
        if input == undefined
            ''
        else
            input.substring(0,1).toUpperCase()+input.substring(1)

.filter 'orderObjectBy', ->
    (items, field, reverse) ->
        filtered = []
        angular.forEach(items, (item) ->filtered.push(item))
        filtered.sort( (a, b) -> if a[field] > b[field] then 1 else -1)
        if reverse
            filtered.reverse()
        filtered

.filter 'secondsToHuman', ->
    (allSeconds) ->
        allDays = allSeconds/86400
        days = Math.floor(allDays)
        allSeconds = allSeconds - days*86400

        allHours = allSeconds/3600
        hours = Math.floor(allHours)
        allSeconds = allSeconds - hours*3600

        allMinutes = allSeconds/60
        minutes = Math.floor(allMinutes)
        allSeconds = allSeconds - minutes*60

        seconds = allSeconds

        if (days > 1)
            return "" + days + " days, " + hours + " hours, " + minutes + " minutes, " + seconds + " seconds"
        if (days == 1)
            return "1 day, " + hours + " hours, " + minutes + " minutes, " + seconds + " seconds"
        if (hours > 1)
            return "" + hours + " hours, " + minutes + " minutes, " + seconds + " seconds"
        if (hours == 1)
            return "1 hour, " + minutes + " minutes, " + seconds + " seconds"
        if (minutes > 1)
            return "" + minutes + " minutes, " + seconds + " seconds"
        if (minutes == 1)
            return "1 minute, " + seconds + " seconds"
        return "" + seconds + " seconds"

.filter 'secondsToClock', ->
    (allSeconds) ->
        if allSeconds == undefined || isNaN(allSeconds)
            return ""
        allHours = allSeconds/3600
        hours = Math.floor(allHours)
        allSeconds = allSeconds - hours*3600

        allMinutes = allSeconds/60
        minutes = Math.floor(allMinutes)
        if minutes < 10
            minutes = "0" + minutes
        allSeconds = allSeconds - minutes*60

        seconds = allSeconds
        if seconds < 10
            seconds = "0" + seconds

        if (hours > 0)
            return "" + hours + ":" + minutes + ":" + seconds + ""
        return "" + minutes + ":" + seconds + ""
