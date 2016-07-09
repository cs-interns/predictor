Predictions = (() ->
  init = () ->
    $('#predict').on 'click', (e) ->
      id = $.Upload.getUploadedFrameId()
      if id
        predict(id)
      return false

  
  getModelId = () ->
    $('select.models-list').val()

  predict = (frame_id) ->
    $.ajax
      url: "http://139.59.249.87/3/Predictions/models/#{encodeURI(getModelId())}/frames/#{encodeURI(frame_id)}.hex"
      method: 'post'
      success: (response) ->
        console.log response

  return {
    init: init
  }
)()
$.extend(Predictions: Predictions)
