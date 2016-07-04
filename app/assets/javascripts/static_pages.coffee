# viewlist = (button, url, ) ->
url = 'http://139.59.249.87'

$(document).ready ->
  $('#model-view').on 'click', ->
    $.getJSON url + '/3/Models', (result) ->
      console.log result
      modelElements = $.map result.models, (model, i) ->
        listItem = $('<li></li>')
        $("<a>#{model.model_id.name} | #{model.algo_full_name} Algorithm </a>" )
        .addClass('model').attr('data-name', model.model_id.name)
        .attr('href', '#').appendTo(listItem)
        return listItem
      $('.models-list').html(modelElements)

  $('div').on 'click', '.model', (e) ->
    e.preventDefault()
    key = $(@).data('name')
    $.getJSON url + '/3/Models/' + key, (result) ->
      console.log(result)

################################################################################

$(document).ready ->
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
