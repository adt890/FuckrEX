pinpoint = ($q, $localStorage, profiles) ->
    #[{lat,lon,dist}] -> {lat,lon}
    # Based on http://gis.stackexchange.com/a/415/41129 
    trilaterate = (beacons) ->
        earthR = 6371
        rad = (deg) -> deg * math.pi / 180
        deg = (rad) -> rad * 180 / math.pi

        [P1, P2, P3] = beacons.map (beacon) -> [
            earthR * math.cos(rad(beacon.lat)) * math.cos(rad(beacon.lon))
            earthR * math.cos(rad(beacon.lat)) * math.sin(rad(beacon.lon))
            earthR * math.sin(rad(beacon.lat))
        ]
        # #from wikipedia
        # #transform to get circle 1 at origin
        # #transform to get circle 2 on x axis
        ex = math.divide(math.subtract(P2, P1), math.norm(math.subtract(P2, P1)))
        i = math.dot(ex, math.subtract(P3, P1))
        ey = math.divide(math.subtract(math.subtract(P3, P1), math.multiply(i, ex)), math.norm(math.subtract(math.subtract(P3, P1), math.multiply(i, ex))))
        ez = math.cross(ex, ey)
        d = math.norm(math.subtract(P2, P1))
        j = math.dot(ey, math.subtract(P3, P1))
        # #from wikipedia
        # #plug and chug using above values
        x = (math.pow(beacons[0].dist, 2) - math.pow(beacons[1].dist, 2) + math.pow(d, 2)) / (2 * d)
        y = (math.pow(beacons[0].dist, 2) - math.pow(beacons[2].dist, 2) + math.pow(i, 2) + math.pow(j, 2)) / (2 * j) - (i / j * x)
        # I was having problems with the number in the radical being negative,
        # so I took the absolute value. Not sure if this is always going to work
        z = math.sqrt(math.abs(math.pow(beacons[0].dist, 2) - math.pow(x, 2) - math.pow(y, 2)))
        # #triPt is an array with ECEF x,y,z of trilateration point
        triPt = math.add(math.add(math.add(P1, math.multiply(x, ex)), math.multiply(y, ey)), math.multiply(z, ez))
        # #convert back to lat/long from ECEF
        # #convert to degrees
        return {
            lat: deg(math.asin(math.divide(triPt[2], earthR)))
            lon: deg(math.atan2(triPt[1], triPt[0]))
        }


    randomizedLocation = ->
        lat: $localStorage.grindrParams.lat + ((Math.random() - 0.5) / 100) #+/- ~500m north
        lon: $localStorage.grindrParams.lon + ((Math.random() - 0.5) / 100) #+/- ~500m east


    return (id) ->
        deferred = $q.defer()

        beacons = [randomizedLocation(), randomizedLocation(), randomizedLocation()]
        promises = beacons.map (location) ->
            params = _.clone($localStorage.grindrParams)
            params.lat = location.lat
            params.lon = location.lon
            profiles.nearby(params)

        $q.all(promises).then (results)->
            for i in [0..2]
                profile = _.findWhere(results[i], {profileId: id})
                return deferred.reject() unless profile
                beacons[i].dist = profile.distance
            deferred.resolve(trilaterate(beacons))

        deferred.promise


angular
    .module('pinpoint', ['profiles'])
    .factory('pinpoint', ['$q', '$localStorage', 'profiles', pinpoint])
