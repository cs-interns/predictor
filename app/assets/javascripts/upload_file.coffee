Upload = (() ->
  # private
  id = 0
  id_len = 6
  columnTypes = []
  columnNames = ''


  uploadAndPredict = (e) ->
      if $(e.target).siblings('input')[0].files.length == 0
        # no file uploaded, use form
        $.Predictions.uploadFromTable()
      else
        uploadAndParse()
      return false

  uploadAndParse = (file) ->
    id = 0  # clear id, new file upload
    upload = uploadFile(file)
    upload.done (response) ->
      # parse
      parseFrame get_id()

  uploadFile = (file) ->
    if file
      fd = new FormData()
      fd.append('file', file)
    else
      fd = new FormData($('form')[0])
    $.ajax
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
        column_names: columnNames
        source_frames: "[\"#{opts.frameName}\"]"
        delete_on_done: true
        column_types: columnTypes
        check_header: 1
      )

  prepareArrayForPost = (obj, key) ->
    data = $.map obj[key], (item, index) ->
      "\"#{item}\""
    data = data.join(',')
    "[#{data}]"

  guessParseParams = (frameName) ->
    $.ajax
      url: 'http://139.59.249.87/3/ParseSetup'
      method: 'post'
      data:
        source_frames: "[\"#{frameName}\"]"

  # public
  get_id = () ->
    id = id || Array(id_len + 1).join((Math.random().toString(36)+'00000000000000000').slice(2, 18)).slice(0, id_len)
    return id

  hasUploaded = () ->
    return id != 0

  setColumnTypes = (t) ->
    types = $.map(t, (type, i) ->
      "\"#{type}\""
    )
    columnTypes = "[#{types.join(',')}]"

  getColumnTypes = () ->
    return columnTypes

  setColumnNames = (n) ->
    names = $.map(n, (name, i) ->
  	  "\"#{name}\""
    )
    columnNames = "[#{names.join(',')}]"
  
  getColumnNames = () ->
    return columnNames

  init = () ->
    attachUploadButtonListener()

  return {
    uploadAndPredict: uploadAndPredict
    getUploadedFrameId: get_id
    uploadAndParse: uploadAndParse
    hasUploaded: hasUploaded
    setColumnTypes: setColumnTypes
    getColumnTypes: getColumnTypes
    setColumnNames: setColumnNames
    getColumnNames: getColumnNames
  }
)()
$.extend(Upload: Upload)
