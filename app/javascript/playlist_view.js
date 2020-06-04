import $ from 'jquery'

document.addEventListener("turbolinks:load", function() {

  // Cached selectors

  var $playlistView = $('[data-js-playlist-view]')
  var $paneOptions = $('[data-js-pane-option]', $playlistView)
  var $panes = $('[data-js-pane]', $playlistView)

  if ($playlistView.length) {

    $paneOptions.first().prop('checked', true)

    // Event handlers

    $paneOptions.on('change', function() {
      var paneName = $(this).val()
      $panes.hide()
      $panes.filter('[data-js-pane=' + paneName + ']').show()
      if (paneName) { loadChartsPane() }
    })

  }

  // Methods

  function loadChartsPane() {
    $.get('/charts', function(data) {
      $panes.filter('[data-js-pane=charts]').html(data)
    })
  }

})