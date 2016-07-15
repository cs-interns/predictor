url = 'http://139.59.249.87'

$(document).ready ->
  $('.models-list').hide()
  $('#loading').show()
  $('.upload-div').hide()
  $('.feature-label').hide()
  $('.data-label').hide()
  
  $('.model-div').on('focus', '#data-row input', (e) ->
    input = $(e.target)
  )

  $('.upload-button').click (e)->
    $.Upload.uploadAndPredict(e)
    return false

  $('.upload-file').change ->
    file = this.files[0]
    console.log file
    # try
    reader = new FileReader()
    #preview first 10 only
    reader.readAsText(file)
    reader.onload = (e) ->
      fileContent = e.target.result
      console.log(fileContent)
      arr = fileContent.split("\n").slice(0, 10)
      # remove the last one
      arr_len = arr.length
      arr = arr.slice 0, arr_len - 1
      arr2 = []
      for line in arr
        arr2.push line.split(",")
      dataTable = $('<table></table>')
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
      console.log arr2
    # catch error
    #   console.log "naay error"


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
  $('.models-list').on 'change', (e) ->
    e.preventDefault()
    key = $(@).val()
    exclude_model_fields = ['models/data_frame', 'models/algo',
    'models/response_column_name',
    'models/output/cross_validation_models', 'models/output/model_summary',
    'models/output/scoring_history']
    $.ajax
      url: "#{url}/3/Models/#{key}"
      data: {'_exclude_fields': exclude_model_fields.join(",")}
      context: @
      timeout: 15000
      beforeSend: ->
        $('#loading').show()
        $('.table-div').hide()
      success: (res) ->
        dataTable = $('<table></table>')
        modelInputMeta = res.models[0].output
        try
          $('.table-div').show()
          dataPoints = $('<thead></thead>')
          $.each res.models[0].output.names, (i, col) ->
            $("<th>#{col}</th>").attr({'id': "#{col}"}).appendTo(dataPoints)
          dataTable.addClass('responsive-table striped view-data').append(dataPoints)
          tableRow = $('<tr></tr>')
          $.each dataPoints.children(), (i, dataPoint) ->
            tableRow.append($('<td>').html($('<input type="text">').data('name', $(dataPoint).html()).data('choices', modelInputMeta.domains[i])))
          tableRow.attr('id', 'data-row')
          dataTable.append tableRow
          $('.table-div').html(dataTable).fadeIn()
        catch e
          $('.table-div').html('<h6>No Columns Found</h6>').addClass('center').fadeIn()
        finally
          $('#loading').hide()
          $('.feature-label').show()
          $('.data-label').show()
          $('.upload-div').show()
          $('.data-div').html('<h6>No Data To Preview</h6>').addClass('center').fadeIn()
      error: (xhr, status, error_thrown) ->
        $('#loading').hide()
        $('.table-div').html('<h5>No Columns Found</h5>').addClass('center').fadeIn()
