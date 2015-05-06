updateProfileController = ($scope, $http, $rootScope, profiles, uploadImage) ->
    profiles.get($rootScope.profileId).then (profile) ->
        $scope.profile = profile

    $scope.updateAttribute = (attribute) ->
        data = {}
        data[attribute] = $scope.profile[attribute]
        unless data == {}
            $http.put('https://primus.grindr.com/2.0/profile', data)

    $scope.$watch 'imageFile', ->
        if $scope.imageFile
            uploadImage.uploadProfileImage($scope.imageFile).then(
                -> alert("Image up for review by some Grindr™ monkey")
                -> alert("Image upload failed")
            )

angular
    .module('updateProfileController', ['file-model', 'uploadImage'])
    .controller('updateProfileController', ['$scope', '$http', '$rootScope', 'profiles', 'uploadImage', updateProfileController])
