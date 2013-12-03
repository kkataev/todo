todoApp = angular.module('TodoApp', ['ngRoute', 'ngAnimate', 'firebase', 'ui.bootstrap', 'ngResource', 'ui.slider']).
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

todoApp.factory("typeaheadData", ->
  init: (Todos) ->
    typeaheadTags = []
    # Typeahead array
    todos = Todos
    if todos != undefined
      for todo in todos
        if todo.tags != undefined
          for tag in todo.tags
            isExist = false
            if typeaheadTags != []
              for _tag in typeaheadTags
                if tag.value == _tag.value
                  isExist = true
            if isExist == false 
              typeaheadTags.push tag

    typeaheadTags
)


todoApp.controller 'CreateCtrl', ($scope, $location, $timeout, Todos, typeaheadData) ->
  
  $scope.tags = []
  $scope.typeaheadTags = typeaheadData.init(Todos)

  $scope.save = ->

    $scope.todo.tags = $scope.tags

    if($scope.todo.tags != undefined)
        sumPoint = 0
        sumSteps = 0
        for tag in $scope.todo.tags
          sumPoint += parseFloat(tag.point)
          sumSteps += 1
        $scope.todo.points = sumPoint/sumSteps

    Todos.add $scope.todo, ->
      $timeout ->
        $location.path "/"

  $scope.removeTag = (tag) ->
    $scope.tags.splice($scope.tags.indexOf(tag), 1);
    console.log($scope.tags)

  $scope.addTag = ->
    $scope.tag.point = '0'
    $scope.tags.push $scope.tag
    $scope.tag = null


todoApp.controller 'EditCtrl', ($scope, $location, $routeParams, angularFire, fbURL, typeaheadData, Todos) ->
  angularFire(fbURL + $routeParams.id, $scope, "remote", {}).then ->
    $scope.typeaheadTags = typeaheadData.init(Todos)

    $scope.todo = angular.copy($scope.remote)
    $scope.todo.$id = $routeParams.todoId
    $scope.tags = $scope.todo.tags

    $scope.isClean = ->
      angular.equals $scope.remote, $scope.todo

    $scope.destroy = ->
      $scope.remote = null
      $location.path "/"

    $scope.save = ->

      $scope.todo.tags = $scope.tags

      if($scope.todo.tags != undefined)
        sumPoint = 0
        sumSteps = 0
        for tag in $scope.todo.tags
          sumPoint += parseFloat(tag.point)
          sumSteps += 1
        $scope.todo.points = sumPoint/sumSteps

      $scope.remote = angular.copy($scope.todo)
      $location.path "/"

    $scope.addTag = ->
      $scope.tag.point = '0'
      $scope.tags.push $scope.tag
      $scope.tag = null

    $scope.removeTag = (tag) ->
      $scope.tags.splice($scope.tags.indexOf(tag), 1);
      console.log($scope.tags)

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
    $(element).slider
      min: 0
      max: 10
      value: $scope.tag.point
      slide: (event, ui) ->
        $scope.tag.point = ui.value
        $scope.$apply()