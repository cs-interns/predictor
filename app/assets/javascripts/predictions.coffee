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
        prediction = response.model_metrics[0].predictions.columns
        result_index = prediction[0].data[0]+1
        result = prediction[result_index]

        #CLASSIFICATION ALGORITHMS
        if result
          label = result.label
        #REGRESSION ALGO (for now)
        else
          label = prediction[0].data

        model_name = response.model.name
        $.ajax
         url: "http://139.59.249.87/3/Models/#{model_name}"
         method: 'get'
         success: (res) ->
          console.log res
          model_rate = parseFloat(res.models[0].output.cross_validation_metrics_summary.data[1][0]) * 100
          model_fit = res.models[0].output
          cv = model_fit.cross_validation_metrics.r2 * 100
          train = model_fit.training_metrics.r2 * 100

          #PREDICTION DETAILS FOR CLASSIFICATION ALGOS
          if result
            confidence = result.mean * 100
            $('.model-rate-label').html(
              "Model Accuracy: "+model_rate.toFixed(2)+"%"+ "<br>" +
              "Confidence: "+confidence.toFixed(2)+"%").fadeIn()
          else 
            $('.model-rate-label').html(
              "Model Fit (CV): "+cv.toFixed(2)+"%" + "<br>"+
              "Model Fit (Training): "+train.toFixed(2)+"%").fadeIn()

          $('.result-label').html(label).fadeIn()
          $('#loading-results').hide()
          

  return {
    predict: predict
  }
)()
$.extend(Predictions: Predictions)
