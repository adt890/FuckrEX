xmpp = require('simple-xmpp')

#Grindr chat messages are JSON objects sent and received with XMPP:
#   addresses: "{profileId}@chat.grindr.com"
#   password: one-time token (see authentication)
#Grindr chat uses HTTP to:
#   - get messages sent while you were offline (/undeliveredChatMessages)
#   - confirm receiption (/confirmChatMessagesDelivered)
#   - notify Grindr you blocked someone (managed by profiles controller)
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
            delete $localStorage.conversations[id] if $localStorage.conversations[id]
            if fromMe then profiles.block(id) else profiles.blockedBy(id)
        else
            createConversation(id) unless $localStorage.conversations[id]
            $localStorage.conversations[id].lastTimeActive = message.timestamp
            message = switch message.type
                when 'text' then {text: message.body}
                when 'map' then {location: angular.fromJson(message.body)}
                when 'image' then {image: angular.fromJson(message.body).imageHash}
                else {text: message.type + ' ' + message.body}
            message.fromMe = fromMe
            $localStorage.conversations[id].messages.push(message)


        $rootScope.$broadcast('new_message')


    acknowledgeMessages = (messageIds) ->
        $http.post('https://primus.grindr.com/2.0/confirmChatMessagesDelivered', {messageIds: messageIds})
    

    $rootScope.$on 'authenticated', (event, token) ->
        xmpp.connect
            jid: "#{$localStorage.profileId}@chat.grindr.com"
            password: token
            host: 'chat.grindr.com'
            preferred: 'PLAIN'
            #disallowTLS: true
        xmpp.on 'online', (data) ->
            chat.connected = true
            $http.get('https://primus.grindr.com/2.0/undeliveredChatMessages').then (response) ->
                messageIds = []
                _(response.data).sortBy((message) -> message.timestamp).forEach (message) ->
                    addMessage(message)
                    messageIds.push(message.messageId)
                if messageIds.length > 0
                    acknowledgeMessages(messageIds)

        #bypassing simple-xmpp as xmpp.on 'message' doesn't work here
        xmpp.conn.on 'stanza', (stanza) ->
            if stanza.is('message')
                message = angular.fromJson(stanza.getChildText('body'))
                addMessage(message)
                #UGLY: acknowledging XMPP messages with HTTP
                acknowledgeMessages([message.messageId])

        xmpp.on 'error', (message) ->
            $rootScope.chatError = true
            xmpp.disconnect()
            alert("chat error: #{message}. If you're using public wifi, XMPP protocol is probably blocked.")


    sendMessage = (type, body, to, save=true) ->
        message =
            targetProfileId: String(to)
            type: type
            messageId: uuid()
            timestamp: Date.now()
            sourceDisplayName: ''
            sourceProfileId: String($localStorage.profileId)
            body: body
        xmpp.send("#{to}@chat.grindr.com", angular.toJson(message))
        addMessage(message) if save

    return {
        sendText: (text, to, save=true) ->
            sendMessage('text', text, to, save)

        getConversation: (id) ->
            $localStorage.conversations[id]
        lastestConversations: ->
            _.sortBy $localStorage.conversations, (conversation) -> - conversation.lastTimeActive
        
        sentImages: $localStorage.sentImages
        sendImage: (imageHash, to) ->
            messageBody = angular.toJson({imageHash: imageHash})
            sendMessage('image', messageBody, to)

        sendLocation: (to) ->
            messageBody = angular.toJson
                lat: $localStorage.grindrParams.lat
                lon: $localStorage.grindrParams.lon
            sendMessage('map', messageBody, to)

        block: (id) ->
            sendMessage('block', null, id)
    }


angular
    .module('chat', ['ngStorage', 'profiles'])
    .factory('chat', ['$http', '$localStorage', '$rootScope', '$q', 'profiles', chat])
