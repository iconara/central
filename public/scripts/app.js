var app = (function() {
  var app = {}
  
  app.start = function() {
    load()
  }
  
  function load() {
    $("#events").append('<li class="loading">loading…</li>')
    $.ajax({
      url: "/history",
      dataType: "json",
      success: populate,
      error: function() {
        console.log(arguments)
      }
    })
  }
  
  function populate(events) {
    $("#events .loading").remove()
    console.log(events)
    $.each(events, function() {
      $("#events").append('<li>' + this.instigator + ': <a href="' + this.url + '">' + this.title + '</a></li>')
    })
  }
  
  return app
})()

$(function() {
  app.start()
})