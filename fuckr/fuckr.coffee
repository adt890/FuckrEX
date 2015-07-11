#necessary to use smileys or copy and paste on Mac...
if typeof process != 'undefined' and process.platform == 'darwin'
    gui = require('nw.gui')
    nativeMenuBar = new gui.Menu({ type: "menubar" })
    nativeMenuBar.createMacBuiltin "Fuckr"
    gui.Window.get().menu = nativeMenuBar

fuckr = angular.module 'fuckr', [
    #works on any browser with SOP disabled
    'ngRoute'
    'profiles'
    'profilesController'
    #requires node-webkit
    'authenticate'
    'chat'
    'chatController'
    'updateLocation'
    'updateProfileController'
]


fuckr.config ['$httpProvider', '$routeProvider', ($httpProvider, $routeProvider) ->
    $httpProvider.defaults.headers.common.Accept = '*/*' #avoids 406 error

    #login form and controller have been replaced by an iFrame and a webRequest interceptor (see authenticate factory)
    $routeProvider.when('/login', templateUrl: 'views/login.html')
    for route in ['/profiles/:id?', '/chat/:id?', '/updateProfile']
        name = route.split('/')[1]
        $routeProvider.when route,
            templateUrl: "views/#{name}.html"
            controller: "#{name}Controller"
]


fuckr.run ['$location', '$injector', 'authenticate', ($location, $injector, authenticate) ->
    #ugly: loading every factory with 'authenticated' event listener
    $injector.get(factory) for factory in ['profiles', 'chat', 'updateLocation']
    authenticate().then(
        -> $location.path('/profiles/')
        -> $location.path('/login')
    )
]


