loginController = ($scope, $location, $localStorage, authentication) ->
    $scope.$storage = $localStorage
    $scope.login = ->
        $scope.logging = true
        success = -> $location.path('/profiles/')
        failure = -> $scope.logging = $scope.$storage.email = $scope.$storage.password = null
        authentication.login($scope.$storage.email, $scope.$storage.password).then(
            -> authentication.authenticate().then(success, -> alert('This account may have been banned'); failure())
            failure
        )
    $scope.tip = ->
        alert("Please sign up using popup window and close it when the 'Create Account' button fades.")

angular
    .module('loginController', ['ngStorage', 'authentication'])
    .controller('loginController', ['$scope', '$location', '$localStorage', 'authentication', loginController])
