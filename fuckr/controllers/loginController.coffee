loginController = ($scope, $location, $localStorage, authentication) ->
    $scope.$storage = $localStorage
    $scope.login = ->
        $scope.logging = true
        authentication.login($scope.$storage.email, $scope.$storage.password).then(
            -> authentication.authenticate().then -> $location.path('/profiles/')
            -> $scope.logging = $scope.$storage.email = $scope.$storage.password = null
        )
    $scope.tip = ->
        alert("Please sign up using popup window and close it when the 'Create Account' button fades.")

angular
    .module('loginController', ['ngStorage', 'authentication'])
    .controller('loginController', ['$scope', '$location', '$localStorage', 'authentication', loginController])
