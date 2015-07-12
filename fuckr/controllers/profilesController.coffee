profilesController = ($scope, $interval, $localStorage, $routeParams, $window, profiles, pinpoint) ->
    #left part: filter form and thumbnails
    $scope.$storage = $localStorage.$default
        location: 'San Francisco, CA'
        grindrParams:
            lat: 37.7833
            lon: -122.4167
            filter:
                ageMinimum: null
                ageMaximum: null
                photoOnly: true
                onlineOnly: false
                page: 1
                quantity: 300

    $scope.refresh = ->
        profiles.nearby($scope.$storage.grindrParams).then (profiles) ->
            $scope.nearbyProfiles = profiles

    $scope.refresh()
    $interval($scope.refresh, 60000)

    autocomplete = new google.maps.places.Autocomplete(document.getElementById('location'))
    google.maps.event.addListener autocomplete, 'place_changed', ->
        place = autocomplete.getPlace()
        $scope.$storage.location = place.formatted_address
        if place.geometry
            $scope.$storage.grindrParams.lat = place.geometry.location.lat()
            $scope.$storage.grindrParams.lon = place.geometry.location.lng()
            $scope.refresh()

    #right part: detailed profile view
    $scope.open = (id) ->
        $scope.isNearbyProfile = parseInt($routeParams.id) != id
        profiles.get(id).then (profile) ->
            $scope.profile = profile
    $scope.open(parseInt($routeParams.id)) if $routeParams.id

    $scope.pinpoint = (id) ->
        $scope.pinpointing = true
        pinpoint(id).then(
            (location) ->
                $scope.pinpointing = false
                url = "https://maps.google.com/?q=loc:#{location.lat},#{location.lon}"
                $window.open(url, '_blank')
            -> $scope.pinpointing = false
        )


angular
    .module('profilesController', ['ngRoute', 'ngStorage', 'profiles', 'pinpoint'])
    .controller 'profilesController',
               ['$scope', '$interval', '$localStorage', '$routeParams', '$window', 'profiles', 'pinpoint', profilesController]
