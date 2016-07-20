Predictions = (() ->
  predict = (e) ->
      id = $.Upload.getUploadedFrameId()
      if id
        predictionMachine(id)
      return false

  uploadFromTable = () ->
    data = prepareData()
    fileBlob = new Blob([data.join('\r\n')], {type: 'text/csv'})
    $.Upload.uploadAndParse(fileBlob)
    
  prepareData = () ->
    columnNames = $.map($('.view-data thead').children(), (col, i) ->
      return $(col).html()
    )
    columnData = $.map($('#data-row').children(), (input, i) ->
      return $(input).find('input').first().val()
    )
    return [columnNames.join(','), columnData.join(',')]

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
        label = result.label
        model_name = response.model.name
        $.ajax
         url: "http://139.59.249.87/3/Models/#{model_name}"
         method: 'get'
         success: (res) ->
          model_rate = parseFloat(res.models[0].output.cross_validation_metrics_summary.data[1][0]) * 100
          confidence = result.mean * 100
          $('.result-label').html(label).fadeIn()
          $('.confidence-rate-label').html("Confidence: "+confidence.toFixed(2)+"%").fadeIn()
          $('.model-rate-label').html("Model Accuracy: "+model_rate.toFixed(2)+"%").fadeIn()
          $('#loading-results').hide()

  return {
    predict: predict
    uploadFromTable: uploadFromTable
  }
)()
$.extend(Predictions: Predictions)
