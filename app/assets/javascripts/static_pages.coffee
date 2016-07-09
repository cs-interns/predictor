url = 'http://139.59.249.87'

$(document).ready ->
  $.Upload.init()
  $.Predictions.init()
  $('.models-list').hide()
  $('#loading').show()
  $('.upload-div').hide()

  $('.upload-file').change ->
    console.log "hey"
    file = this.files[0]
    console.log file
    # try
    reader = new FileReader()

    reader.readAsText(file)
    reader.onload = (e) ->
      fileContent = e.target.result
      arr = fileContent.split("\n")
      arr2 = []
      for line in arr
        arr2.push line.split(",")
      tableBody = $('<tbody></tbody>')
      for lines in arr2
        tableRow = $('<tr></tr>')
        for data in lines
          tableRow.append ("<td>#{data}</td>")
        tableBody.append tableRow

      $('.table-div').find('table').html tableBody
      console.log arr2
    # catch error
    #   console.log "naay error"


  retrieveModels = ->
    $.getJSON url + '/3/Models', (result) ->
      modelElements = $.map result.models, (model, i) ->
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
    'models/response_column_name', 'models/output/domains',
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
        model = res.models[0].output.names
        dataTable = $('<table></table>')
        try
          console.log(model)
          dataPoints = $('<thead></thead>')
          columns = $.map res.models[0].output.names, (col, i) ->
            $("<th>#{col}</th>").attr({'id': "#{col}"}).appendTo(dataPoints)
            dataPoints
          dataTable.addClass('responsive-table striped view-data').append columns
          $('.table-div').html(dataTable).fadeIn()
        catch e
          $('.table-div').html('<h5>No Columns Found</h5>').addClass('center').fadeIn()
        finally
          $('#loading').hide()
          $('.upload-div').show()
