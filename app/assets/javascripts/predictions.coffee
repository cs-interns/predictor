Predictions = (() ->
  init = () ->
    $('#predict').on 'click', (e) ->
      id = $.Upload.uploadedFrameId()
      if id
        predict(id)
      return false

  
  getModelId = () ->
    $('select.models-list').val()

  predict = (frame_id) ->
    $.ajax
      url: "http://139.59.249.87/3/Predictions/#{encodeURI(getModelId())}/frames/#{encodeURI(frame_id)}.hex"

  return {
    init: init
  }
)()
$.extend(Predictions: Predictions)
