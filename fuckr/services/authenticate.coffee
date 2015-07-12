#Grindr authentication process:
#   login (only once on a typical phone):
#       POST https://account.grindr.com/sessions with email and password
#       to get profile id and multiple-uses authentication token
#   create session (every time):
#       POST https://primus.grindr.com/2.0/session with multiple-uses authentication token
#       to get session ID and one-time XMPP token
authenticateFactory = ($localStorage, $http, $rootScope, $q, $location) ->
    s4 = -> Math.floor((1 + Math.random()) * 0x10000).toString(16).substring(1)
    uuid = -> "#{s4()}#{s4()}-#{s4()}-#{s4()}-#{s4()}-#{s4()}#{s4()}#{s4()}".toUpperCase()
    $localStorage.deviceAuthentifier = $localStorage.deviceAuthentifier || uuid()

    $rootScope.profileId = $localStorage.profileId


    #POST https://account.grindr.com/sessions?locale=en returns 302 grindr-account://*
    #so normal browsers don't pass response data to JavaScript
    #Solution before Grindr used login captchas: NodeJS HTTP
    #New solution: login form in iFrame intercepting response with chrome.webRequest
    onSuccessfulLogin = (response) ->
        redirection_link = _.findWhere(response.responseHeaders, name: "Location").value
        $localStorage.authenticationToken = redirection_link.split('authenticationToken=')[1].split('&')[0]
        $rootScope.profileId = $localStorage.profileId = parseInt(redirection_link.split('profileId=')[1])
        #This belongs neither to a factory nor to a controller :/
        authenticateFunction().then(
            -> $location.path('/profiles')
            -> alert('Your account is probably banned')
        )

        return cancel: true
    chrome.webRequest.onHeadersReceived.addListener(
        onSuccessfulLogin,
        urls: [
            'https://account.grindr.com/sessions?locale=en'
            'https://account.grindr.com/users?locale=en'
        ],
        ['responseHeaders', 'blocking']
    )

    authenticateFunction = ->
        $q (resolve, reject) ->
            return reject('no authentication token') unless $localStorage.authenticationToken
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


    #Using $rootScope avoids a topBarLogoutButtonController.
    $rootScope.logoutAndRestart = ->
        #bypassing ngStorage to delete key immediately
        localStorage.removeItem('ngStorage-authenticationToken')
        window.location.reload('/')

    #primus.grindr.com 401's if the same account is used on two devices at the same time
    #There is no way to prevent 401 login popups on a regular browser (AJAX hooks happen after user's response)
    chrome.webRequest.onAuthRequired.addListener($rootScope.logoutAndRestart, urls: ["<all_urls>"])


    return authenticateFunction


angular
.module('authenticate', ['ngStorage'])
.factory('authenticate', ['$localStorage', '$http', '$rootScope', '$q', '$location', authenticateFactory])
