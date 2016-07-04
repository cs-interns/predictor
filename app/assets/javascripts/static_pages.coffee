url = 'http://139.59.249.87'

$(document).ready ->
  $('.models-list').hide()
  $('#loading').show()
  $('.predict-button').hide()
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
        $('.form-div').hide()
      success: (res) ->
        model = res.models[0]
        dataForm = $('.data-form')
        try
          console.log(model)
          columns = $.map res.compatible_frames[0].columns, (col, i) ->
            dataPoint = $('<div></div>')
            $('<input>').attr({'id': "#{col.label}"}).appendTo(dataPoint)
            $("<label>#{col.label}</label>").attr({'for': "#{col.label}"}).appendTo(dataPoint)
            dataPoint.addClass('input-field col s12 m12 l12')
            dataPoint
          dataForm.html(columns)
          dataForm.closest('.form-div').find('.predict-button').show()
          dataForm.closest('.form-div').fadeIn()
        catch e
          $('.form-div').html('<h5>No Columns Found</h5>').addClass('center').fadeIn()
        finally
          $('#loading').hide()

  $('.data-form').on 'click', (e) ->
    $(e.target).siblings('label').addClass('active')
    $(e.target).on
  $('.data-form').on 'blur','input', (e) ->
    if !e.target.value
      $(e.target).siblings('label').removeClass('active')
      console.log(e)
