updateLocation = ($rootScope, $http, $localStorage, $interval) ->
    $rootScope.$on 'authenticated', ->
        $interval ->
            $http.put 'https://primus.grindr.com/2.0/location',
                lat: $localStorage.grindrParams.lat
                lon: $localStorage.grindrParams.lon
                profileId: $localStorage.profileId
        , 90000
angular
    .module('updateLocation', [])
    .service('updateLocation', ['$rootScope', '$http', '$localStorage', '$interval', updateLocation])
