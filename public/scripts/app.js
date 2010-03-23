var createList = function(type) {
  var element = $('<ul></ul>')

  element.addClass(type)
  
  element.showLoading = function() {
    element.addRow("loading…", "loading")
  }
  
  element.hideLoading = function() {
     $(".loading", element).remove()
  }
  
  element.rowHeight = function() {
    return $("*:first-child", element).height()
  }
  
  element.addRow = function(text, cls) {
    var row = $('<li>' + text + '</li>')
    row.addClass(cls)
    element.append(row)
  }
  
  element.addHeader = function(str) {
    element.before('<h2>' + str + '</h2>')
  }
  
  return element
}

var app = (function() {
  var app = {}
  
  var eventsList
  var legendList
  
  app.start = function() {
    eventsList = createList("events")
    legendList = createList("legend")
    
    install()
    load()
  }
  
  function install() {
    $(".events-placeholder").replaceWith(eventsList)
    $(".legend-placeholder").replaceWith(legendList)
  }
  
  function load() {
    loadTypes()
    loadEvents()
  }
  
  function loadTypes() {
    legendList.showLoading()
    
    $.ajax({
      url: "/types",
      dataType: "json",
      success: populateLegend,
      error: legendError
    })
  }
  
  function populateLegend(types) {
    legendList.hideLoading()
    
    $.each(types, function() {
      legendList.addRow(this.toString(), this.toString())
    })
  }
  
  function legendError() {
    legendList.hideLoading()
    legendList.addRow("error while loading legend", "error")
  }
  
  function loadEvents() {
    eventsList.showLoading()
    
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
  
  function populateEvents(events) {
    eventsList.hideLoading()
    
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
  
  function eventsError() {
    eventsList.hideLoading()
    eventsList.addRow("error while loading events", "error")
  }
  
  return app
})()

$(function() {
  app.start()
})