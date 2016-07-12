Predictions = (() ->
  predict = (e) ->
      id = $.Upload.getUploadedFrameId()
      if id
        predictionMachine(id)
      return false


  getModelId = () ->
    $('select.models-list').val()

  predictionMachine = (frame_id) ->
    $.ajax
      url: "http://139.59.249.87/3/Predictions/models/#{encodeURI(getModelId())}/frames/#{encodeURI(frame_id)}.hex"
      method: 'post'
      beforeSend: ->
       $('#loading-results').show()
      success: (response) ->
        console.log response
        prediction = response.model_metrics[0].predictions.columns
        result_index = prediction[0].data[0]+1
        result = prediction[result_index]
        label = result.label
        rate = result.mean * 100
        $('.result-label').html(label).fadeIn()
        $('.rate-label').html("Accuracy: "+rate.toFixed(2)+"%").fadeIn()
        $('#loading-results').hide()

  return {
    predict: predict
  }
)()
$.extend(Predictions: Predictions)
