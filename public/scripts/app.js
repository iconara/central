$.fn.bounds = function() {
  var bounds = {}
  var offset = $(this).offset()
  
  bounds.top = offset.top
  bounds.left = offset.left
  bounds.width = $(this).outerWidth()
  bounds.height = $(this).outerHeight()
  
  return bounds
}

var createList = function(type, addMode) {
  var element = $('<ul></ul>')
  
  addMode = addMode || "append"

  element.addClass(type)
  
  element.showLoading = function() {
    if (addMode == "append") {
      element.addRow("loading…", "loading")
    } else {
      element.prependRow("loading…", "loading") 
    }
  }
  
  element.hideLoading = function() {
     $(".loading", element).remove()
  }
  
  element.rowHeight = function() {
    return $("*:first-child", element).height()
  }
  
  function createRow(text, cls) {
    var row = $('<li>' + text + '</li>')
    row.addClass(cls)
    return row
  }
  
  element.addRow = function(text, cls) {
    element.append(createRow(text, cls))
  }
  
  element.prependRow = function(text, cls) {
    element.prepend(createRow(text, cls))
  }
  
  element.addHeader = function(str) {
    element.before('<h2>' + str + '</h2>')
  }
  
  element.clear = function() {
    element.empty()
    element.siblings("h2").remove()
  }
  
  return element
}

var createLogInController = function(form, authenticatedCallback) {
  var controller = {authenticated: false}
  
  var trigger = $(trigger)
  var form = $(form)
  var passwordField = $("input[type=password]", form)
  
  $(form).submit(logIn)
  $(passwordField).focus(resetErrors)
  
  controller.isAuthenticated = function() {
    return controller.authenticated
  }
  
  controller.checkAuthentication = function() {
    $.ajax({url: "/ping", success: loggedIn, error: showPasswordForm})
  }
  
  function showPasswordForm() {
    form.show()
  }
  
  function hidePasswordForm() {
    form.hide()
  }
  
  function resetErrors() {
    passwordField.removeClass("error")
    $("div.error", form).remove()
  }
  
  function logIn(e) {
    e.preventDefault()
    
    resetErrors()
    
    var password = $("input[type=password]", this).val()
    
    if ($.trim(password).length > 0) {
      $.ajax({
        url: "/session",
        type: "POST",
        data: {password: password},
        dataType: "json",
        success: loggedIn,
        error: logInError,
        beforeSend: disableForm,
        complete: enableForm
      })
    }
  }
  
  function disableForm() {
    $("input", form).attr("disabled", "disabled")
  }
  
  function enableForm() {
    $("input", form).attr("disabled", null)
  }
  
  function loggedIn() {
    controller.authenticated = true
    
    hidePasswordForm()
    
    if (authenticatedCallback) {
      authenticatedCallback()
    }
  }
  
  function logInError(request, status, error) {
    if (request.status == 401) {
      passwordField.addClass("error")
      form.append('<div class="error">wrong password!</div>')
    } else {
      form.append('<div class="error">unknown authentication error</div>')
    }
  }
  
  return controller
}

var createEventLoader = function(loadedListener, errorListener) {
  var loader = {}
  
  var types
  var history
  
  loader.load = function() {
    $.ajax({
      url: "/types",
      dataType: "json",
      success: onTypesLoaded,
      error: onTypesError
    })
    
    $.ajax({
      url: "/history",
//    data: {"limit": n},
      dataType: "json",
      success: onHistoryLoaded,
      error: onHistoryError
    })
  }
  
  function onTypesLoaded(data) {
    types = data

    if (history) {
      onBothLoaded()
    }
  }
  
  function onHistoryLoaded(data) {
    history = data
    
    if (types) {
      onBothLoaded()
    }
  }
  
  function onBothLoaded() {
    loadedListener(types, history)
  }
  
  function onTypesError(e) {
    errorListener("types", e)
  }
  
  function onHistoryError(e) {
    errorListener("history", e)
  }
  
  return loader
}

var app = (function() {
  var app = {}
  
  var UPDATE_INTERVAL = 5 * 60 * 1000
  
  var eventsList
  var legendList
  
  var activeLoader
  var updateTimer
  
  app.start = function() {
    eventsList = createList("events", "prepend")
    legendList = createList("legend", "append")
    logInController = createLogInController("#login-form", onAuthenticated)
    
    install()

    logInController.checkAuthentication()
  }
  
  app.forceLoad = function() {
    load()
  }
  
  function install() {
    $(".events-placeholder").replaceWith(eventsList)
    $(".legend-placeholder").replaceWith(legendList)
  }
  
  function onAuthenticated() {
    $("#login-trigger").hide()
    $("#content").show()
    
    enableAutoUpdate()
    
    load()
  }
  
  function enableAutoUpdate() {
    updateTimer = setInterval(autoUpdate, UPDATE_INTERVAL)
  }
  
  function disableAutoUpdate() {
    clearInterval(updateTimer)
  }
  
  function autoUpdate() {
    load()
  }
  
  function load() {
    if (activeLoader == null) {
      legendList.showLoading()
      eventsList.showLoading()

      activeLoader = createEventLoader(onEventsLoaded, onLoadError)
      activeLoader.load()
    }
  }
  
  function onEventsLoaded(types, events) {
    legendList.hideLoading()
    eventsList.hideLoading()
    
    populateLegend(types)
    populateEvents(events)
    
    activeLoader = null
  }
  
  function onLoadError(which, errorEvent) {
    if (which == "types") {
      legendList.hideLoading()
      legendList.addRow("error while loading legend", "error")
    } else if (which == "history") {
      eventsList.hideLoading()
      eventsList.addRow("error while loading events", "error")
    }
  }
  
  function populateLegend(types) {
    legendList.clear()
    
    $.each(types, function() {
      legendList.addRow(this.toString(), this.toString())
    })
  }
  
  function populateEvents(events) {
    eventsList.clear()
    
    if (events.length > 0) {
      eventsList.addHeader(formatDate(events[0].date))
    
      var previous = events[0]
    
      $.each(events, function() {
        if (formatDate(previous.date) != formatDate(this.date)) {
          var newEventsList = createList("events")
          eventsList.after(newEventsList)
          eventsList = newEventsList
          eventsList.addHeader(formatDate(this.date))
        }
      
        var line = '<a href="' + this.url + '">' + this.title + '</a>'
        
        if (this.instigator) {
          line = this.instigator + ': ' + line
        }
      
        eventsList.addRow(line, this.type)
        
        previous = this
      })
    }
  }
  
  function formatDate(date) {
    if (typeof date == "string") {
      date = new Date(date)
    }
    
    return date.getFullYear() + '-' + zeroFill(date.getMonth() + 1, 2) + '-' + zeroFill(date.getDate(), 2)
  }
  
  function zeroFill(n, length) {
    var str = "" + n
    
    while (str.length < length) {
      str = "0" + str
    }
    
    return str
  }
    
  return app
})()

$(function() {
  app.start()
})