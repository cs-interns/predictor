Predictions = (() ->
  init = () ->
    false

  getModelId = () ->
    $('select.models-list').val()

  predict = (frame_id) ->
    $.ajax
      url: "http://139.59.249.87/3/Predictions/#{encodeURI(getModelId())}/frames/#{encodeURI(frame_id)}"

  return {
    init: init
  }
)()
$.extend(Predictions: Predictions)
