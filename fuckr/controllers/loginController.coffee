loginController = ($scope, $location, authentication) ->
    $scope.login = ->
        authentication.login($scope.email, $scope.password).then(
            -> authentication.authenticate().then -> $location.path('/profiles/')
            -> $scope.email = $scope.password = ''
        )
    $scope.tip = ->
        alert("Please sign up using popup window and close it when the 'Create Account' button fades.")

angular
    .module('loginController', ['authentication'])
    .controller('loginController', ['$scope', '$location', 'authentication', loginController])
