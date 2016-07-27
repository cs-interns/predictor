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
        if result
          label = result.label
        else
          label = prediction[0].data

        model_name = response.model.name
        prediction_frame = "http://139.59.249.87"+response.predictions_frame.URL
        $.ajax
         url: "http://139.59.249.87/3/Models/#{model_name}"
         method: 'get'
         success: (res) ->
          model_rate = parseFloat(res.models[0].output.cross_validation_metrics_summary.data[1][0]) * 100
          if result
            confidence = result.mean * 100
            $('.confidence-rate-label').html("Confidence: "+confidence.toFixed(2)+"%").fadeIn()
          $('.result-label').html(label).fadeIn()
          $('.model-rate-label').html("Model Accuracy: "+model_rate.toFixed(2)+"%").fadeIn()
          $('#loading-results').hide()
          $('.show-button').show()

          $('.show-button').click ->
            label = $(this)
            $('.prediction-details').slideToggle ->
              if ($(this).is(':visible'))
                label.text('Show Less Details')
                $.ajax
                  url: prediction_frame
                  method: 'get'
                  success: (res_prediction) ->
                    console.log res_prediction
                    frame = res_prediction.frames 
                    frame_name = frame[0].frame_id.name
                    $('.prediction-name').html("Frame name: " + frame_name)

              else
                label.text('Show More Details')

  return {
    predict: predict
  }
)()
$.extend(Predictions: Predictions)
