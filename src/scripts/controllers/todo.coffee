TodoApp = angular.module('TodoApp', []);

TodoApp.controller 'TodoCtrl', ($scope) ->

  $scope.todos = [
    text: "learn angular"
    tags: [
      "home"
      "important"
    ]
    done: true
  ,
    text: "build an angular app"
    tags: ["work"]
    done: false
  ]
  $scope.addTodo = ->
    $scope.todos.push
      text: $scope.todoText
      tags: $scope.todoTags
      done: false

    $scope.todoText = ""
    $scope.todoTags = ""

  $scope.remaining = ->
    count = 0
    angular.forEach $scope.todos, (todo) ->
      count += (if todo.done then 0 else 1)

    count

  $scope.archive = ->
    oldTodos = $scope.todos
    $scope.todos = []
    angular.forEach oldTodos, (todo) ->
      $scope.todos.push todo  unless todo.done