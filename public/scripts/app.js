var app = (function() {
  var app = {}
  
  app.start = function() {
    install()
    
    load()
  }
  
  function install() {
    $(".events-placeholder").replaceWith(createEventsElement())
    $(".legend-placeholder").replaceWith(createLegendElement())
  }
  
  function createLegendElement() {
    return $('<ul class="legend"></ul>')
  }
  
  function createEventsElement() {
    return $('<ul class="events"></ul>')
  }
  
  function legendElement() {
    return $("ul.legend").last()
  }

  function eventsElement() {
    return $("ul.events").last()
  }

  function showEventsLoading() {
    eventsElement().append('<li class="loading">loading…</li>')
  }
  
  function showLegendLoading() {
    legendElement().append('<li class="loading">loading…</li>')
  }
  
  function hideEventsLoading() {
    $(".loading", eventsElement()).remove()
  }
  
  function hideLegendLoading() {
    $(".loading", legendElement()).remove()
  }
  
  function rowHeight() {
    return $("*:first-child", eventsElement()).height()
  }
  
  function load() {
    loadTypes()
    loadEvents()
  }
  
  function loadTypes() {
    showLegendLoading()
    
    $.ajax({
      url: "/types",
      dataType: "json",
      success: populateLegend,
      error: legendError
    })
  }
  
  function populateLegend(types) {
    hideLegendLoading()
    
    $.each(types, function() {
      legendElement().append('<li class="' + this + '">' + this + '</li>')
    })
  }
  
  function legendError() {
    hideLegendLoading()
    legendElement().append('<li class="error">error while loading legend</li>')
  }
  
  function loadEvents() {
    showEventsLoading()
    
    var n = 100 //Math.floor((window.innerHeight - eventsElement().offset().top)/rowHeight()) 
    
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
    eventsElement().before('<h2>' + str + '</h2>')
  }
  
  function populateEvents(events) {
    hideEventsLoading()
    
    if (events.length > 0) {
      addHeader(formatDate(events[0].date))
    
      var previous = events[0]
    
      $.each(events, function() {
        if (formatDate(previous.date) != formatDate(this.date)) {
          eventsElement().after(createEventsElement())
          addHeader(formatDate(this.date))
        }
      
        var line = '<a href="' + this.url + '">' + this.title + '</a>'
        
        if (this.instigator) {
          line = this.instigator + ': ' + line
        }
      
        eventsElement().append('<li class="' + this.type + '">' + line + '</li>')
        
        previous = this
      })
    }
  }
  
  function eventsError() {
    hideEventsLoading()
    eventsElement().append('<li class="error">error while loading events</li>')
  }
  
  return app
})()

$(function() {
  app.start()
})