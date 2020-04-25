import consumer from './consumer'
import $ from 'jquery'

$(document).ready(function() {

  var location_id = $('[data-js-weather]').attr('data-js-weather')

  consumer.subscriptions.create({ channel: 'WeatherChannel', location_id: location_id }, {
    received(data) {
      $('[data-js-weather]').replaceWith(data)
    }
  })

})