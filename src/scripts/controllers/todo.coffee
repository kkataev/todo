todoApp = angular.module('TodoApp', ['ngRoute', 'firebase']).
  value("fbURL", "https://kkataev-todos.firebaseio.com/").
  factory("Todos", (angularFireCollection, fbURL) ->
    angularFireCollection fbURL
  )
todoApp.config ["$routeProvider", ($routeProvider) ->
    $routeProvider
      .when("/edit/:id",
      templateUrl: "views/edit.html"
      controller: "EditCtrl"
    ).when("/new",
      templateUrl: "views/new.html"
      controller: "CreateCtrl"
    ).when("/home",
      templateUrl: "views/body.html"
      controller: "ListCtrl"
    ).otherwise redirectTo: "/home"
  ]

todoApp.controller 'ListCtrl', ($scope, Todos) ->
  $scope.todos = Todos

  $scope.remaining = ->
    count = 0
    angular.forEach $scope.todos, (todo) ->
      count += (if todo.done then 0 else 1)
    count


todoApp.controller 'CreateCtrl', ($scope, $location, $timeout, Todos) ->
  $scope.save = ->
    console.log($scope.todo)
    Todos.add $scope.todo, ->
      $timeout ->
        $location.path "/"


todoApp.controller 'EditCtrl', ($scope, $location, $routeParams, angularFire, fbURL) ->
  angularFire(fbURL + $routeParams.id, $scope, "remote", {}).then ->
    $scope.todo = angular.copy($scope.remote)
    $scope.todo.$id = $routeParams.todoId
    $scope.isClean = ->
      angular.equals $scope.remote, $scope.todo

    $scope.destroy = ->
      $scope.remote = null
      $location.path "/"

    $scope.save = ->
      $scope.remote = angular.copy($scope.todo)
      $location.path "/"