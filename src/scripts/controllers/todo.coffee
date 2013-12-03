todoApp = angular.module('TodoApp', ['ngRoute', 'ngAnimate', 'firebase', 'ui.bootstrap', 'ngResource', 'ui.slider']).
  value("fbURL", "https://kkataev-todos.firebaseio.com/todos/")

todoApp.config ["$routeProvider", ($routeProvider) ->
    $routeProvider
      .when("/edit/:id",
      templateUrl: "views/edit.html"
      controller: "EditCtrl"
      authRequired: true
    ).when("/new",
      templateUrl: "views/new.html"
      controller: "CreateCtrl"
      authRequired: true
    ).when("/home",
      templateUrl: "views/body.html"
      controller: "ListCtrl"
      authRequired: true
    ).when("/login",
      templateUrl: "views/login.html"
      controller: "LoginCtrl"
      authRequired: false,
    ).otherwise redirectTo: "/home"
  ]

todoApp.controller 'ListCtrl', ($scope, angularFireAuth, angularFireCollection, fbURL) ->

  angularFireAuth.initialize fbURL,
    scope: $scope
    name: "user"
    path: "/login"

  $scope.$on "angularFireAuth:login", (evt, user) ->
    $scope.todos = angularFireCollection fbURL

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
            console.log(tag)
            if typeaheadTags != []
              for _tag in typeaheadTags
                if tag.value == _tag.value
                  isExist = true
            if isExist == false 
              typeaheadTags.push tag
    console.log(typeaheadTags)       
    typeaheadTags
)


todoApp.controller 'CreateCtrl', ($scope, $location, $timeout, typeaheadData, angularFireAuth, angularFireCollection, fbURL) ->
  
  angularFireAuth.initialize fbURL,
    path: "/login"
    scope: $scope
    name: "user"

  $scope.$on "angularFireAuth:login", (evt, user) ->
    Todos = angularFireCollection fbURL
    $scope.todos = Todos

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


todoApp.controller 'EditCtrl', ($scope, $location, $routeParams, angularFireAuth, angularFire, angularFireCollection, fbURL, typeaheadData) ->

  angularFireAuth.initialize fbURL,
    path: "/login"
    scope: $scope
    name: "user"

  $scope.$on "angularFireAuth:login", (evt, user) ->
    Todos = angularFireCollection fbURL
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

todoApp.controller 'LoginCtrl', ($scope, angularFire, angularFireAuth, fbURL) ->
  url = fbURL
  $scope.form = {}
  $scope.login = ->
    console.log "called"
    username = $scope.form.username
    password = $scope.form.password
    angularFireAuth.login "password",
      email: username
      password: password
      rememberMe: true


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