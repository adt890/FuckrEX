chatController = ($scope, $routeParams, chat) ->
    $scope.lastestConversations = chat.lastestConversations()

    $scope.open = (id) ->
        $scope.conversationId = id
        $scope.conversation = chat.getConversation(id)
        $scope.sentImages = null
    $scope.open($routeParams.id) if $routeParams.id

    $scope.$on 'new_message', ->
        $scope.conversation = chat.getConversation($scope.conversationId)
        $scope.lastestConversations = chat.lastestConversations()

    $scope.sendText = ->
        chat.sendText($scope.message, $scope.conversationId)
        $scope.message = ''

    
    $scope.showSentImages = ->
        $scope.sentImages = chat.getSentImages()
    
    $scope.$watch 'imageFile', ->
        #Vanilla JS trick to figure out image dimensions...
        img = new Image
        img.src = URL.createObjectURL($scope.imageFile)
        img.onload = ->
            chat.uploadImage($scope.imageFile, img.width, img.height).then ->
                $scope.sentImages = chat.getSentImages()


    $scope.sendImage = (imageHash) ->
        chat.sendImage(imageHash, $scope.conversationId)
        
    $scope.sendLocation = ->
        chat.sendLocation($scope.conversationId)

    $scope.block = ->
        if confirm('Sure you want to block him?')
            chat.block($scope.conversationId)
            $scope.conversationId = null
            $scope.lastestConversations = chat.lastestConversations()


angular.
    module('chatController', ['ngRoute', 'file-model', 'chat']).
    controller('chatController', ['$scope', '$routeParams', 'chat', chatController])
