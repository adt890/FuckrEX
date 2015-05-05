xmpp = require('simple-xmpp')


chat = ($http, $localStorage, $rootScope, $q, profiles) ->
    s4 = -> Math.floor((1 + Math.random()) * 0x10000).toString(16).substring(1)
    uuid = -> "#{s4()}#{s4()}-#{s4()}-#{s4()}-#{s4()}-#{s4()}#{s4()}#{s4()}".toUpperCase()


    $localStorage.conversations = $localStorage.conversations || {}
    $localStorage.sentImages = $localStorage.sentImages || []

    createConversation = (id) ->
        $localStorage.conversations[id] =
            id: id
            messages: []
        profiles.get(id).then (profile) ->
            $localStorage.conversations[id].thumbnail = profile.profileImageMediaHash


    addMessage = (message) ->
        if parseInt(message.sourceProfileId) == $localStorage.profileId
            fromMe = true
            id = parseInt(message.targetProfileId)
        else
            fromMe = false
            id = parseInt(message.sourceProfileId)

        return if profiles.isBlocked(id)

        if message.type == 'block'
            profiles.blockedBy(id)
            delete $localStorage.conversations[id] if $localStorage.conversations[id]
        else
            createConversation(id) unless $localStorage.conversations[id]
            $localStorage.conversations[id].lastTimeActive = message.timestamp
            message = switch message.type
                when 'text' then {text: message.body}
                when 'location' then {text: '*SENT LOCATION*'}
                when 'image' then {image: angular.fromJson(message.body).imageHash}
                else {text: message.type + ' ' + message.body}
            message.fromMe = fromMe
            $localStorage.conversations[id].messages.push(message)


        $rootScope.$broadcast('new_message')
    

    $rootScope.$on 'authenticated', (event, token) ->
        xmpp.connect
            jid: "#{$localStorage.profileId}@chat.grindr.com"
            password: token
            host: 'chat.grindr.com'
            preferred: 'PLAIN'
            disallowTLS: true
        xmpp.on 'online', (data) ->
            chat.connected = true
            $http.get('https://primus.grindr.com/2.0/undeliveredChatMessages').then (response) ->
                data = messageIds: []
                _(response.data).sortBy((message) -> message.timestamp).forEach (message) ->
                    addMessage(message)
                    data.messageIds.push(message.messageId)
                if data.messageIds.length > 0
                    $http.post('https://primus.grindr.com/2.0/confirmChatMessagesDelivered', data)

        #bypassing simple-xmpp as xmpp.on 'message' doesn't work here
        xmpp.conn.on 'stanza', (stanza) ->
            if stanza.is('message')
                message = angular.fromJson(stanza.getChildText('body'))
                addMessage(message)

        xmpp.on 'error', (message) ->
            $rootScope.chatError = true
            alert("chat error: #{message}")

    return {
        send: (text, to) ->
            message =
                targetProfileId: String(to)
                type: 'text'
                messageId: uuid()
                timestamp: Date.now()
                sourceDisplayName: ''
                sourceProfileId: String($localStorage.profileId)
                body: text
            xmpp.send("#{to}@chat.grindr.com", angular.toJson(message))
            addMessage(message)

        getConversation: (id) ->
            $localStorage.conversations[id]
        lastestConversations: ->
            _.sortBy $localStorage.conversations, (conversation) -> - conversation.lastTimeActive
            #_.toArray $localStorage.conversations

        block: (id) ->
            delete $localStorage.conversations[id] if $localStorage.conversations[id]
            profiles.block(id)
    }


angular
    .module('chat', ['ngStorage', 'profiles'])
    .factory('chat', ['$http', '$localStorage', '$rootScope', '$q', 'profiles', chat])
