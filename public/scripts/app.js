var app = (function() {
  var app = {}
  
  app.start = function() {
    install()
    
    load()
  }
  
  function install() {
    $(".events-placeholder").replaceWith(createListElement())
  }
  
  function createListElement() {
    return $('<ul class="events"></ul>')
  }

  function listElement() {
    return $("ul.events").last()
  }

  function showLoading() {
    listElement().append('<li class="loading">loading…</li>')
  }
  
  function hideLoading() {
    $(".loading", listElement()).remove()
  }
  
  function rowHeight() {
    return $("*:first-child", listElement()).height()
  }
  
  function load() {
    showLoading()
    
    var n = 100 //Math.floor((window.innerHeight - listElement().offset().top)/rowHeight()) 
    
    $.ajax({
      url: "/history",
//      data: {"limit": n},
      dataType: "json",
      success: populate,
      error: error
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
    listElement().before('<h2>' + str + '</h2>')
  }
  
  function populate(events) {
    hideLoading()
    
    if (events.length > 0) {
      addHeader(formatDate(events[0].date))
    
      var previous = events[0]
    
      $.each(events, function() {
        if (formatDate(previous.date) != formatDate(this.date)) {
          listElement().after(createListElement())
          addHeader(formatDate(this.date))
        }
      
        var line = '<a href="' + this.url + '">' + this.title + '</a>'
        
        if (this.instigator) {
          line = this.instigator + ': ' + line
        }
      
        listElement().append('<li class="' + this.type + '">' + line + '</li>')
        
        previous = this
      })
    }
  }
  
  function error() {
    listElement().append('<li class="error">error while loading events</li>')
  }
  
  return app
})()

$(function() {
  app.start()
})