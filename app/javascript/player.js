import $ from 'jquery'

window.onSpotifyWebPlaybackSDKReady = function() {

  // Cached selectors

  var $player = $('[data-js-player]')
  var $playPlaylistButton = $('[data-js-play-playlist]', $player)
  var $error = $('[data-js-error]', $player)
  var $tracks = $('[data-js-spotify-track]', $player)
  var $controlBar = $('[data-js-control-bar]')
  var $playButton = $('[data-js-play]', $player)
  var $pauseButton = $('[data-js-pause]', $player)
  var $prevButton = $('[data-js-prev]', $player)
  var $nextButton = $('[data-js-next]', $player)
  var $scrubber = $('[data-js-scrubber]', $player)
  var $image = $('[data-js-image]', $player)
  var $title = $('[data-js-title]', $player)
  var $albumInfo = $('[data-js-album-info]', $player)

  // Initialization

  if ($player.length) {
    var token = $player.attr('data-js-player')
    var spotifyPlayer = ''
    var deviceId = ''
    var scrubberTimer = null

    var trackUris = $tracks.map(function() {
      return `spotify:track:${$(this).attr('data-js-spotify-track')}`
    }).get()

    initializeSpotifyPlayer()

    // Event handlers

    $playPlaylistButton.on('click', function() {
      playTrack($tracks.first().attr('data-js-spotify-track'))
    })

    $tracks.on('click', function() {
      playTrack($(this).attr('data-js-spotify-track'))
    })

    $playButton.on('click', function() {
      spotifyPlayer.resume()
    })

    $pauseButton.on('click', function() {
      spotifyPlayer.pause()
    })

    $prevButton.on('click', function() {
      spotifyPlayer.previousTrack()
    })

    $nextButton.on('click', function() {
      spotifyPlayer.nextTrack()
    })

    $scrubber.on('input', function() {
      updateScrubberPosition()
    })
  }

  // Methods

  function initializeSpotifyPlayer() {
    spotifyPlayer = new Spotify.Player({
      name: 'Cloudnine Player',
      getOAuthToken: cb => { cb(token) }
    })

    spotifyPlayer.addListener('ready', function(info) {
      console.log('Spotify player ready!')
      deviceId = info.device_id
    })

    spotifyPlayer.addListener('player_state_changed', function(state) {
      if (!state.paused) {
        startScrubberUpdates()
        updateNowPlaying()
        $playButton.hide()
        $pauseButton.show()
      } else {
        stopScrubberUpdates()
        $playButton.show()
        $pauseButton.hide()
      }
    })

    spotifyPlayer.addListener('initialization_error', function(msg) {
      showError('Could not initialize Spotify player. This is probably because you are using an unsupported browser.', msg)
    })

    spotifyPlayer.addListener('authentication_error', function(msg) {
      showError('Could not authenticate with Spotify. Try logging out and logging back in.', msg)
    })
    
    spotifyPlayer.addListener('account_error', function() {
      showError('Could not validate your Spotify account. Playback is only supported if you have Spotify Premium (but you can still export your playlist to your Spotify, even if you have a free account).', msg)
    })

    spotifyPlayer.addListener('playback_error', function() {
      showError('Could not play that song. Check your internet connection and try again.', msg)
    })

    spotifyPlayer.connect()
  }

  function showError(userMsg, consoleMsg = false) {
    $error.show()
    $error.text(userMsg)
    $error.delay(11000).hide(0)
    if (consoleMsg) {
      console.log(consoleMsg)
    }
  }

  function playTrack(trackId) {
    fetch(`https://api.spotify.com/v1/me/player/play?device_id=${deviceId}`, {
      method: 'PUT',
      body: JSON.stringify({
        uris: trackUris,
        offset: { uri: `spotify:track:${trackId}` }
      }),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`
      },
    }).catch(() => {
      showError('You must have Spotify Premium to play songs. However, you can still export your playlist to Spotify by clicking the "Export" button.')
    })
  }

  function startScrubberUpdates() {
    scrubberTimer = setInterval(function() {
      spotifyPlayer.getCurrentState().then(state => {
        $scrubber.val(state.position / state.duration * 1000)
      })
    }, 250)
  }

  function stopScrubberUpdates() {
    clearInterval(scrubberTimer)
  }

  function updateScrubberPosition() {
    spotifyPlayer.getCurrentState().then(state => {
      spotifyPlayer.seek($scrubber.val() / 1000 * state.duration)
    })
  }

  function updateNowPlaying() {
    spotifyPlayer.getCurrentState().then(state => {
      var track = state.track_window.current_track
      $title.text(track.name)
      $albumInfo.text(track.artists[0].name + ' — ' + track.album.name)
      $image.attr('src', track.album.images[0].url)
      $controlBar.show()
    })
  }

}