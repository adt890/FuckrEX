request = require('request')


authentication = ($localStorage, $http, $rootScope, $q) ->
    s4 = -> Math.floor((1 + Math.random()) * 0x10000).toString(16).substring(1)
    uuid = -> "#{s4()}#{s4()}-#{s4()}-#{s4()}-#{s4()}-#{s4()}#{s4()}#{s4()}".toUpperCase()

    $localStorage.deviceAuthentifier = $localStorage.deviceAuthentifier || uuid()
    $rootScope.profileId = $localStorage.profileId

    return {
        authenticate: ->
            $q (resolve, reject) ->
                $http.post 'https://primus.grindr.com/2.0/session',
                    appName: "Grindr"
                    appVersion: "2.2.3"
                    authenticationToken: $localStorage.authenticationToken
                    deviceIdentifier: $localStorage.deviceAuthentifier
                    platformName: "Android" #iOS
                    platformVersion: "19"   #7.0.4
                    profileId: $localStorage.profileId
                .error ->
                    $localStorage.authenticationToken = null
                    reject('wrong token or no connection')
                .success (data, status, headers, config) ->
                    sessionId = headers()['session-id']
                    $http.defaults.headers.common['Session-Id'] = sessionId
                    $http.defaults.headers.common['Cookies'] = "Session-Id=#{sessionId}"
                    $rootScope.$emit('authenticated', data.xmppToken)
                    $rootScope.authenticated = true
                    resolve()

        login: (email, password) ->
            $q (resolve, reject) ->
                #using node.js because browser won't let you access response
                #after unknown URL protocol exception (starting grindr-account://)
                req = request.post('https://account.grindr.com/sessions?locale=en')
                req.form({email: email, password: password})
                req.on 'response', (response) ->
                    redirection_link = response.headers.location
                    if redirection_link
                        $localStorage.authenticationToken = redirection_link.split('authenticationToken=')[1].split('&')[0]
                        $rootScope.profileId = $localStorage.profileId = parseInt(redirection_link.split('profileId=')[1])
                        resolve()
                    else
                        reject()
    }


angular
    .module('authentication', ['ngStorage'])
    .factory('authentication', ['$localStorage', '$http', '$rootScope', '$q', authentication])
