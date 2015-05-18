fuckr = angular.module 'fuckr', [
    #works on any browser with SOP disabled
    'ngRoute'
    'profiles'
    'profilesController'
    #requires node-webkit
    'authentication'
    'loginController'
    'chat'
    'chatController'
    'updateLocation'
    'updateProfileController'
]


fuckr.config ['$httpProvider', '$routeProvider', ($httpProvider, $routeProvider) ->
    $httpProvider.defaults.headers.common.Accept = '*/*' #avoids 406 error

    #unfortunately requires HTTP basic auth to be disabled
    $httpProvider.interceptors.push ->
        responseError: (response) ->
            if response.status == 401
                window.logoutAndRestart(false)
            else
                return response

    for route in ['/profiles/:id?', '/chat/:id?', '/login', '/updateProfile']
        name = route.split('/')[1]
        $routeProvider.when route,
            templateUrl: "views/#{name}.html"
            controller: "#{name}Controller"
]


fuckr.run ['$location', '$injector', 'authentication', ($location, $injector, authentication) ->
    #ugly: loading every factory with 'authenticated' event listener
    $injector.get(factory) for factory in ['profiles', 'chat', 'updateLocation']
    authentication.authenticate().then(
        -> $location.path('/profiles/')
        -> $location.path('/login')
    )
]


