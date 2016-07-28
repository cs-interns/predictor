url = 'http://139.59.249.87'

$(document).ready ->
  $('.modal-trigger').leanModal();
  $('.models-list').hide()
  $('#loading').show()
  $('#predict').hide()
  $('.upload-div').hide()
  $('#model-specs').hide()
  $('.feature-label').hide()
  $('.data-label').hide()
  $('.show-button').hide()
  $('.prediction-details').hide()

  $('.results-div').pushpin({ top: $('.results-div').offset().top })

  $('#model-specs').on('click', '#detail-trigger', (e) ->
    e.preventDefault()
    e.stopPropagation()
  )

  $('.modal-footer').on('click', '.modal-close', (e) ->
    e.preventDefault()
  )

  $(window).on "scroll", () ->
    if($('.results-div').hasClass('pinned'))
      $('.results-div').addClass('push-m7 push-s7 push-l7')
    else if ($('.results-div').hasClass('pin-top'))
      $('.results-div').removeClass('push-m7 push-s7 push-l7')


  $('.upload-button').click (e)->
    $.Upload.uploadAndPredict(e)
    return false

  $('.upload-file').change ->
    file = this.files[0]
    # try
    reader = new FileReader()
    #preview first 10 only
    reader.readAsText(file)
    reader.onload = (e) ->
      fileContent = e.target.result
      arr = fileContent.split("\n").slice(0, 10)
      # remove the last one
      arr_len = arr.length
      arr = arr.slice 0, arr_len - 1
      arr2 = []
      for line in arr
        arr2.push line.split(",")
      dataTable = $('<table>', {id: 'preview-table'})
      tableHead = $('<thead></thead>')
      tableBody = $('<tbody></tbody>')
      for lines in arr2
        if lines == arr2[0]
          for data in lines
            tableHead.append ("<th>#{data}</th>")
        else
          tableRow = $('<tr></tr>')
          for data in lines
            tableRow.append ("<td>#{data}</td>")
        tableBody.append tableRow
        dataTable.addClass("responsive-table striped").append(tableHead).append(tableBody)
      $('.data-div').html dataTable
      $('.data-label').show()
      $('#predict').show()
      # $('.table-div').find('table').html tableBody

  #GET MODELS FROM H2O
  retrieveModels = ->
    $.getJSON url + '/3/Models', (result) ->
      modelElements = $.map result.models, (model, i) ->
        unless model.model_id.name.match(/_cv_\d+/g)
          $("<option>#{model.model_id.name} | #{model.algo_full_name} Algorithm </option>" )
          .addClass('model').attr('data-name', model.model_id.name)
          .attr({'href': '#', 'value': "#{model.model_id.name}"})
      $('.models-list').append(modelElements)
      $('select').material_select()
      $('#loading').hide()
  retrieveModels()

  #DISPLAY FEATURES OF MODEL EVERY CHANGE
  $('.models-list').on 'change', (e) ->
    e.preventDefault()
    key = $(@).val()
    exclude_model_fields = ['models/data_frame', #'models/algo',
    'models/response_column_name', 'models/output/domains',
    'models/output/cross_validation_models'] # , 'models/output/model_summary',
    # 'models/output/scoring_history']
    $.ajax
      url: "#{url}/3/Models/#{key}"
      data: {'_exclude_fields': exclude_model_fields.join(",")}
      context: @
      timeout: 15000
      beforeSend: ->
        $('#loading').show()
        $('.table-div').hide()
      success: (res) ->
        model_name = res.models[0].model_id.name
        trainingFrame = (() ->
          modelParams = res.models[0].parameters
          for param in modelParams
            if param.name == 'training_frame'
              return param.actual_value.name
        )()
        dataTable = $('<table></table>')
        try
          $('.table-div').show()
          dataPoints = $('<thead></thead>')
          columns = $.map res.models[0].output.names, (col, i) ->
            $("<th>#{col}</th>").attr({'id': "#{col}"}).appendTo(dataPoints)
            dataPoints
          row = $('<tr>')
          for x in [0...columns.length - 1]
            row.append($('<td>', {html: $('<input>', {type: 'text'})}))
          dataTable.addClass('responsive-table striped view-data').append(columns).append(row)
          $('.table-div').html(dataTable).fadeIn()
          $.ModelDetails.showModelDetail res.models[0], $('#modal1')
        catch e
          $('.table-div').html('<h6>No Columns Found</h6>').addClass('center').fadeIn()
        finally
          $('#loading').hide()
          $('#model-specs').fadeIn('slow')
          $('.feature-label').show()
          $('.data-label').show()
          $('.upload-div').show()
          $('.data-div').html('<h6>No Data To Preview</h6>').addClass('center').fadeIn()
          $('.result-label').hide()
          $('.confidence-rate-label').hide()
          $('.model-rate-label').hide()
          $('.show-button').hide()

          #DISPLAY RESPONSE COLUMN NAME EVERY CHANGE OF MODEL
          $.ajax
            url: "http://139.59.249.87/3/Models/#{model_name}"
            method: 'get'
            success: (res_col) ->
              response_column = res_col.models[0].response_column_name
              $('.predict-col').html(response_column)

      error: (xhr, status, error_thrown) ->
        $('#loading').hide()
        $('.table-div').html('<h5>No Columns Found</h5>').addClass('center').fadeIn()
        $('.result-label').hide()
        $('.confidence-rate-label').hide()
        $('.model-rate-label').hide()
        $('.show-button').hide()
