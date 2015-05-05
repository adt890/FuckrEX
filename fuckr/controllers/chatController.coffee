chatController = ($scope, $routeParams, $location, chat) ->
    $scope.lastestConversations = chat.lastestConversations()

    $scope.open = (id) ->
        $scope.conversationId = id
        $scope.conversation = chat.getConversation(id)
    $scope.open($routeParams.id) if $routeParams.id

    $scope.$on 'new_message', ->
        $scope.conversation = chat.getConversation($scope.conversationId)
        $scope.lastestConversations = chat.lastestConversations()

    $scope.send = ->
        chat.send($scope.message, $scope.conversationId)
        $scope.message = ''

    $scope.block = ->
        if confirm('Sure you want to block him?')
            chat.block($scope.conversationId)
            $location.path('/chat/')


angular.
    module('chatController', ['ngRoute', 'chat']).
    controller('chatController', ['$scope', '$routeParams', '$location', 'chat', chatController])
