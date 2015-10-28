angular.module('uploadImage', []).factory 'uploadImage', ['$http', '$q', ($http, $q) ->
    uploadImage = (file, urlFunction) ->
        deferred = $q.defer()
        #dirty vanilla JS trick to figure out dimensions
        img = new Image
        img.src = URL.createObjectURL(file)
        img.onload = ->
            $http
                method: "POST"
                url: urlFunction(img.width, img.height)
                data: file
                headers:
                    'Content-Type': file.type
            .then (response) ->
                deferred.resolve(response.data.mediaHash)
        deferred.promise
    
    return {
        uploadChatImage: (file) ->
            uploadImage file, (width, height) ->
                #*Image/MaxY,MinX,MaxX,MinY of the crop
                "https://neo-upload.grindr.com/2.0/chatImage/#{height},0,#{width},0"

        uploadProfileImage: (file) ->
            uploadImage file, (width, height) ->
                squareSize = _.min([width, height])
                "https://neo-upload.grindr.com/2.0/profileImage/#{height},0,#{width},0/#{squareSize},0,#{squareSize},0"
    }
]
