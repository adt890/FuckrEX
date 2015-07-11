#gets, caches and blocks profiles
profiles = ($http, $q, $rootScope) ->
    profileCache = {}

    blocked = []
    $rootScope.$on 'authenticated', ->
        $http.get('https://primus.grindr.com/2.0/blocks').then (response) ->
            blocked = _.intersection(response.data.blockedBy, response.data.blocking)

    return {
        nearby: (params) ->
            deferred = $q.defer()
            $http.post('https://primus.grindr.com/2.0/nearbyProfiles', params).then (response) ->
                profiles = _.reject response.data.profiles, (profile) ->
                    _.contains(blocked, profile.profileId)

                for profile in profiles when not profileCache[profile.profileId]
                    profileCache[profile.profileId] = profile
                deferred.resolve(profiles)
            deferred.promise

        get: (id) ->
            if profileCache[id]
                $q.when(profileCache[id])
            else
                deferred = $q.defer()
                $http.post('https://primus.grindr.com/2.0/getProfiles', {targetProfileIds: [id]}).then (response) ->
                    deferred.resolve(response.data[0])
                deferred.promise

        blockedBy: (id) ->
            blocked.push(id)
            delete profileCache[id]

        block: (id) ->
            this.blockedBy(id)
            $http.post('https://primus.grindr.com/2.0/blockProfiles', {targetProfileIds: [id]})

        isBlocked: (id) -> _.contains(blocked, id)
    }


angular
    .module('profiles', [])
    .factory('profiles', ['$http', '$q', '$rootScope', profiles])
    
