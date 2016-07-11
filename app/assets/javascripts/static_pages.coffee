url = 'http://139.59.249.87'

$(document).ready ->
  $.Upload.init()
  $('.models-list').hide()
  $('#loading').show()
  $('.upload-div').hide()
  $('.feature-label').hide()
  $('.data-label').hide()

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
      # $('.table-div').find('table').html tableBoddy
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
    $.ajax
      url: "#{url}/3/Models/#{key}"
      data: 'find_compatible_frames': true
      context: @
      timeout: 15000
      beforeSend: ->
        $('#loading').show()
        $('.table-div').hide()
      success: (res) ->
        model = res.models[0]
        dataTable = $('<table></table>')
        try
          $('.table-div').show()
          console.log(model)
          dataPoints = $('<thead></thead>')
          columns = $.map res.compatible_frames[0].columns, (col, i) ->
            $("<th>#{col.label}</th>").attr({'id': "#{col.label}"}).appendTo(dataPoints)
            dataPoints
          dataTable.addClass('responsive-table striped view-data').append columns
          $('.table-div').html(dataTable).fadeIn()
        catch e
          $('.table-div').html('<h5>No Columns Found</h5>').addClass('center').fadeIn()
        finally
          $('#loading').hide()
          $('.feature-label').show()
          $('.upload-div').show()
