url = 'http://139.59.249.87'

$(document).ready ->
  retrieveModels = ->
    console.log 'hello'
    $.getJSON url + '/3/Models', (result) ->
      console.log result
      modelElements = $.map result.models, (model, i) ->
        listItem = $('<option></option>')
        $("<a>#{model.model_id.name} | #{model.algo_full_name} Algorithm </a>" )
        .addClass('model').attr('data-name', model.model_id.name)
        .attr({'href': '#', 'value': "#{model.model_id.name}"}).appendTo(listItem)
        return listItem
      $('.models-list').html(modelElements).show()
  window.onload = retrieveModels
  $('div').on 'click', '.model', (e) ->
    e.preventDefault()
    key = $(@).data('name')
    $.ajax
      url: "#{url}/3/Models/#{key}"
      data: 'find_compatible_frames': true
      context: @
      timeout: 15000
      success: (res) ->
        model = res.models[0]
        holder = $ '<li>'
        $(@).after holder
        item = $(@).detach()
        try
          columns = $.map res.compatible_frames[0].columns, (col, i) ->
            li = $ '<li>'
            li.html col.label
            li.data 'type', col.type
            li
          item.append $('<ul>')
          item.find('ul').append columns
        catch e
          console.log 'No columns found.'
        finally
          holder.replaceWith item

#####################################################success, do something with the file###########################

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
  
  $('form input').on 'change', () ->
    # preview file

  $('form button').on 'click', (e) ->
    if $(this).siblings('input')[0].files.length == 0
      return false
    upload = uploadFile()
    upload.done (response) ->
      # parse
      parseFrame 'uploaded.hex'
    return false;

guessParseParams = (frameName) ->
  $.ajax
    url: 'http://139.59.249.87/3/ParseSetup'
    method: 'post'
    data:
      source_frames: "[\"#{frameName}\"]"

prepareArrayForPost = (obj, key) ->
  data = $.map obj[key], (item, index) ->
    "\"#{item}\""
  data = data.join(',')
  "[#{data}]"

parseFrame = (frameName) ->
  guess = guessParseParams(frameName)
  guess.done (params) ->

    # delete some params, server errors out with these params
    exclude_params = [
      'data'
      'header_lines'
      'total_filtered_column_count'
      'warnings'
      'na_strings'
      '__meta'
      'column_offset'
      'column_count'
      'column_name_filter'
    ]
    delete params[x] for x in exclude_params

    # set our parameters
    $.extend(params,
      destination_frame: 'parsed.hex'
      column_names: prepareArrayForPost(params, 'column_names')
      column_types: prepareArrayForPost(params, 'column_types')
      source_frames: "[\"#{frameName}\"]")

    # send off to parse
    $.ajax
      url: 'http://139.59.249.87/3/Parse'
      data: params
      method: 'post'

uploadFile = () ->
  fd = new FormData($('form')[0])
  
  $.ajax
    url: 'http://139.59.249.87/3/PostFile?destination_frame=uploaded.hex'
    data: fd
    method: 'post'
    processData: false
    contentType: false
    cache: false
