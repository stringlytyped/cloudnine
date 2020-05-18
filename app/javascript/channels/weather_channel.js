import consumer from './consumer'
import $ from 'jquery'

document.addEventListener("turbolinks:load", function() {

  if ($('[data-js-weather]').length) {
    var location_id = $('[data-js-weather]').attr('data-js-weather')

    consumer.subscriptions.create({ channel: 'WeatherChannel', location_id: location_id }, {
      received(data) {
        $('[data-js-weather]').replaceWith(data)
      }
    })
  }

})