angular.module('signoutController', ['authentication']).controller 'signoutController', ['$scope', 'authentication', ($scope, authentication) ->
    $scope.signout = ->
        if confirm('Wanna sign out?')
            authentication.forgetCredentials()
            #verrryyy ugly: waiting for angular&ngRoute to update localStorage...
            setTimeout (-> window.location.reload('/')), 500
]
