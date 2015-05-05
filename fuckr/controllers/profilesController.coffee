profilesController = ($scope, $interval, $localStorage, $routeParams, profiles) ->
    $scope.$storage = $localStorage.$default
        location: 'San Francisco, CA'
        grindrParams:
            lat: 37.7833
            lon: -122.4167
            filter:
                ageMinimum: 18
                ageMaximum: 40
                photoOnly: true
                onlineOnly: false
                page: 1
                quantity: 150

    $scope.refresh = ->
        profiles.nearby($scope.$storage.grindrParams).then (profiles) ->
            $scope.nearbyProfiles = profiles

    $scope.refresh()
    $interval($scope.refresh, 60000)

    autocomplete = new google.maps.places.Autocomplete(document.getElementById('location'))
    google.maps.event.addListener autocomplete, 'place_changed', ->
        place = autocomplete.getPlace()
        if place.geometry
            $scope.$storage.grindrParams.lat = place.geometry.location.lat()
            $scope.$storage.grindrParams.lon = place.geometry.location.lng()
            $scope.refresh()

    $scope.open = (id) ->
        profiles.get(id).then (profile) ->
            $scope.profile = profile
    $scope.open(parseInt($routeParams.id)) if $routeParams.id


angular
    .module('profilesController', ['ngRoute', 'ngStorage', 'profiles'])
    .controller 'profilesController',
               ['$scope', '$interval', '$localStorage', '$routeParams', 'profiles', profilesController]
