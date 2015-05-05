updateProfileController = ($scope, $http, $rootScope, profiles) ->
    profiles.get $rootScope.profileId, (profile) ->
        $scope.profile = profile

    updateAttribute(attribute) ->
        data = {}
        data[attribute] = $scope.profile[attribute]
        $http.put('https://primus.grindr.com/2.0/profile', data)

    ###
    $scope.$on "cropme:done", (event, result, canvas) ->
        url =
            'https://upload.grindr.com/2.0/profileImage/' +
            "#{result.height},0,#{result.width},0/" +
            "#{result.y + $scope.squareSize},#{result.x},#{result.x + $scope.squareSize},#{result.y}" #MaxY, MinX, MaxX, MinY of the crop

        $http
            method: 'POST'
            url: url
            headers:
                'Content-Type': result.originalImage.type
            data: result.originalImage
        .success -> alert 'yeah'
        .error -> alert 'oh noes'
    ###


angular
    .module('updateProfileController', [])
    .controller('updateProfileController', ['$scope', '$http', '$rootScope', 'profiles', updateProfileController])
