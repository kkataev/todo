todoApp = angular.module('TodoApp', ['ngRoute', 'firebase', 'ui.bootstrap', 'ngResource', 'ui.slider']).
  value("fbURL", "https://kkataev-todos.firebaseio.com/todos/").
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
    )
    .when("/tags",
      templateUrl: "views/tags.html"
      controller: "TagsCtrl"
    ).otherwise redirectTo: "/home"
  ]

todoApp.controller 'ListCtrl', ($scope, Todos) ->
  $scope.todos = Todos

  $scope.remaining = ->
    count = 0
    for todo in $scope.todos
      count += (if todo.done then 0 else 1)
    count

todoApp.controller 'CreateCtrl', ($scope, $location, $timeout, Todos) ->
  
  $scope.tags = []
  $scope.autocompleteTags = []

  $scope.todos = Todos
  for todo in $scope.todos
    for tag in todo.tags
      isExist = false
      for _tag in $scope.autocompleteTags
        if tag.value == _tag.value
          isExist = true
      if isExist == false 
        $scope.autocompleteTags.push tag

  $scope.save = ->
    $scope.todo.tags = $scope.tags
    Todos.add $scope.todo, ->
      $timeout ->
        $location.path "/"

  $scope.addTag = ->
    $scope.tag.point = '0'
    $scope.tags.push $scope.tag
    $scope.tag = null


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

todoApp.controller 'TagsCtrl', ($scope, $location, $routeParams, angularFire, fbURL, Todos) ->
  $scope.todos = Todos
  $scope.save = ->
    Todos.update $scope.todos, ->
      $timeout ->
        $location.path "/"

  ## DIRECTIVES

todoApp.directive 'ngEnter', ->
  ($scope, element, attrs) ->
    element.bind "keydown keypress", (event) ->
      if event.which is 13
        $scope.$apply ->
          $scope.$eval attrs.ngEnter
        event.preventDefault()

todoApp.directive 'ngSlider', ->
  ($scope, element) ->
    $('div.ui-slider').slider
      min: 0
      max: 10
      slide: (event, ui) ->
        $scope.tag.point = ui.value
        $scope.$apply()
      change: (event, ui) ->
        $scope.tag.point = ui.value
        $scope.$apply()
