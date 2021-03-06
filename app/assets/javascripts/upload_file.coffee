Upload = (() ->
  # private
  id = 0
  id_len = 6
  columnNames = []
  columnTypes = []

  prepareTable = () ->
    headers = $('.view-data thead th').map (i, head) ->
      $(head).html()
    values = $('.view-data tbody tr').children().map (i, td) ->
      $(td).find('input').val()
    string = [$.makeArray(headers).join(','), $.makeArray(values).join(',')].join('\r\n')
    return new Blob([string], {type: 'text/csv'})

  uploadAndPredict = (e) ->
      data = 0
      if $(e.target).siblings('input')[0].files.length == 0
        # no file chosen, use manual input
        data = prepareTable()
      id = 0  # clear id, new file upload
      columnNames = []
      columnTypes = []
      uploadPromise = uploadFile(data)
      framePromise = getTrainingFrame()
      $.when(uploadPromise, framePromise).then (uploadResponse, frameResponse) ->

        if data
          headerObjects = $('.view-data thead th')
        else
          headerObjects = $('#preview-table thead').children()

        uploadedColumnNames = $.map headerObjects, (td, i) ->
          return td.innerHTML

        trainingColumns = frameResponse.frames[0].columns
        trainingColumnNames = $.map trainingColumns, (col, i) ->
          return col.label

        columns = $.map uploadedColumnNames, (uploadedColumnName, i) ->
          index = $.inArray uploadedColumnName, trainingColumnNames
          if index >= 0
            return {name: trainingColumns[index].label, type: trainingColumns[index].type}

        $.each columns, (i, column) ->
          columnNames.push(column.name)
          columnTypes.push(column.type)

        parseFrame(get_id())

      return false

  uploadFile = (data) ->
    if data
      fd = new FormData()
      fd.append('file', data)
    else
      fd = new FormData($('form')[0])
    return $.ajax
      url: "http://139.59.249.87/3/PostFile?destination_frame=#{encodeURIComponent(get_id())}"
      data: fd
      method: 'post'
      processData: false
      contentType: false
      cache: false
      beforeSend: ->
          $("#loading-upload").show()

  parseFrame = (frameName) ->
    guess = guessParseParams(frameName)
    guess.done (params) ->
      params = deleteExtraParams(params)
      params = setParseParams(params, frameName: frameName)
      # send off to parse
      $.ajax
        url: 'http://139.59.249.87/3/Parse'
        data: params
        method: 'post'
        success: () ->
          Materialize.toast('Upload succesful!', 1000)
          $("#loading-upload").hide()
          $.Predictions.predict()

  deleteExtraParams = (params) ->
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
    return params

  setParseParams = (params, opts) ->
      # set our parameters
      return $.extend(params,
        destination_frame: "#{get_id()}.hex"
        column_names: prepareArrayForPost(columnNames)
        column_types: prepareArrayForPost(columnTypes)
        source_frames: "[\"#{opts.frameName}\"]"
        delete_on_done: true
      )

  prepareArrayForPost = (arr) ->
    data = $.map arr, (item, index) ->
      "\"#{item}\""
    data = data.join(',')
    return "[#{data}]"

  guessParseParams = (frameName) ->
    return $.ajax
      url: 'http://139.59.249.87/3/ParseSetup'
      method: 'post'
      data:
        source_frames: "[\"#{frameName}\"]"
        check_header: 1

  getTrainingFrame = () ->
    modelName = $('select.models-list').val()
    promise = $.Deferred()
    $.ajax(
      url: "http://139.59.249.87/3/Models/#{modelName}"
      method: 'get'
      success: (response) ->
        trainingFrameURL = response.models[0].data_frame.URL
        $.ajax(
          url: "http://139.59.249.87#{trainingFrameURL}"
          method: 'get'
          success: (response) ->
            promise.resolve(response)
        )
    )
    return promise

  # public
  get_id = () ->
    id = id || Array(id_len + 1).join((Math.random().toString(36)+'00000000000000000').slice(2, 18)).slice(0, id_len)
    return id

  init = () ->
    attachUploadButtonListener()

  return {
    uploadAndPredict: uploadAndPredict
    getUploadedFrameId: get_id
  }
)()
$.extend(Upload: Upload)
