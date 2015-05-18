loginController = ($scope, $location, authentication) ->
    $scope.login = ->
        $scope.logging = true
        authentication.login($scope.email, $scope.password).then(
            -> authentication.authenticate().then -> $location.path('/profiles/')
            -> $scope.logging = $scope.email = $scope.password = null
        )
    $scope.tip = ->
        alert("Please sign up using popup window and close it when the 'Create Account' button fades.")

angular
    .module('loginController', ['authentication'])
    .controller('loginController', ['$scope', '$location', 'authentication', loginController])
