url = 'http://139.59.249.87'

$(document).ready ->
  $.Upload.init()
  $.Predictions.init()
  $('.models-list').hide()
  $('#loading').show()

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
          console.log(model)
          dataPoints = $('<thead></thead>')
          columns = $.map res.compatible_frames[0].columns, (col, i) ->
            $("<th>#{col.label}</th>").attr({'id': "#{col.label}"}).appendTo(dataPoints)
            dataPoints
          dataTable.addClass('responsive-table striped').append columns
          $('.table-div').html(dataTable).fadeIn()
        catch e
          $('.table-div').html('<h5>No Columns Found</h5>').addClass('center').fadeIn()
        finally
          $('#loading').hide()

  $('#frame-view').on 'click', ->
    $.getJSON url + '/3/Frames', (result) ->
      console.log result
      modelElements = $.map result.frames, (frame, i) ->
        listItem = $('<li></li>')
        $("<a>#{frame.frame_id.name}</a>" )
        .addClass('frame').attr('data-name', frame.frame_id.name)
        .attr('href', '#').appendTo(listItem)
        return listItem
      $('.frames-list').html(modelElements)

  $('div').on 'click', '.frame', (e) ->
    e.preventDefault()
    key = $(@).data('name')
    $.getJSON url + '/4/Frames/' + key, (result) ->
      console.log(result)
