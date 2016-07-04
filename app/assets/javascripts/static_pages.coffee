url = 'http://139.59.249.87'

$(document).ready ->

  retrieveModels = ->
    $.getJSON url + '/3/Models', (result) ->
      modelElements = $.map result.models, (model, i) ->
        $("<option>#{model.model_id.name} | #{model.algo_full_name} Algorithm </option>" )
        .addClass('model').attr('data-name', model.model_id.name)
        .attr({'href': '#', 'value': "#{model.model_id.name}"})
      $('.models-list').append(modelElements)
      $('select').material_select()
  window.onload = retrieveModels

  $('.models-list').on 'change', (e) ->
    e.preventDefault()
    key = $(@).val()
    $.ajax
      url: "#{url}/3/Models/#{key}"
      data: 'find_compatible_frames': true
      context: @
      timeout: 15000
      success: (res) ->
        model = res.models[0]
        dataForm = $('.data-form')
        try
          console.log(model)
          columns = $.map res.compatible_frames[0].columns, (col, i) ->
            dataPoint = $('<div></div>')
            $('<input>').attr({'id': "#{col.label}"}).appendTo(dataPoint)
            $("<label>#{col.label}</label>").attr({'for': "#{col.label}"}).addClass('active').appendTo(dataPoint)
            dataPoint.addClass('input-field col s12 m12 l12')
            dataPoint
          dataForm.append columns
          Materialize.updateTextFields()
        catch e
          console.log 'No columns found.'
