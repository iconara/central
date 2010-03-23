var app = (function() {
  var app = {}
  
  app.start = function() {
    install()
    
    load()
  }
  
  function install() {
    $(".events-placeholder").replaceWith(createListElement("events"))
    $(".legend-placeholder").replaceWith(createListElement("legend"))
  }
  
  function createListElement(type) {
    return $('<ul class="' + type + '"></ul>')
  }
    
  function listElement(which) {
    return $("ul." + which).last()
  }

  function showListLoading(which) {
    listElement(which).append('<li class="loading">loading…</li>')
  }
    
  function hideListLoading(which) {
    $(".loading", listElement(which)).remove()
  }
  
  function rowHeight() {
    return $("*:first-child", listElement("events")).height()
  }
  
  function load() {
    loadTypes()
    loadEvents()
  }
  
  function loadTypes() {
    showListLoading("legend")
    
    $.ajax({
      url: "/types",
      dataType: "json",
      success: populateLegend,
      error: legendError
    })
  }
  
  function populateLegend(types) {
    hideListLoading("legend")
    
    $.each(types, function() {
      listElement("legend").append('<li class="' + this + '">' + this + '</li>')
    })
  }
  
  function legendError() {
    hideListLoading("legend")
    listElement("legend").append('<li class="error">error while loading legend</li>')
  }
  
  function loadEvents() {
    showListLoading("events")
    
    var n = 100 //Math.floor((window.innerHeight - listElement("legend").offset().top)/rowHeight()) 
    
    $.ajax({
      url: "/history",
//      data: {"limit": n},
      dataType: "json",
      success: populateEvents,
      error: eventsError
    })
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
  
  function addHeader(str) {
    listElement("events").before('<h2>' + str + '</h2>')
  }
  
  function populateEvents(events) {
    hideListLoading("events")
    
    if (events.length > 0) {
      addHeader(formatDate(events[0].date))
    
      var previous = events[0]
    
      $.each(events, function() {
        if (formatDate(previous.date) != formatDate(this.date)) {
          listElement("events").after(createListElement("events"))
          addHeader(formatDate(this.date))
        }
      
        var line = '<a href="' + this.url + '">' + this.title + '</a>'
        
        if (this.instigator) {
          line = this.instigator + ': ' + line
        }
      
        listElement("events").append('<li class="' + this.type + '">' + line + '</li>')
        
        previous = this
      })
    }
  }
  
  function eventsError() {
    hideListLoading("events")
    listElement("events").append('<li class="error">error while loading events</li>')
  }
  
  return app
})()

$(function() {
  app.start()
})