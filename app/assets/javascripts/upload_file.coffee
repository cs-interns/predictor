Upload = (() ->
  # private
  id = 0
  id_len = 6


  uploadAndPredict = (e) ->
      if $(e.target).siblings('input')[0].files.length == 0
        return false
      id = 0  # clear id, new file upload
      upload = uploadFile()
      upload.done (response) ->
        # parse
        parseFrame get_id()
      return false;

  uploadFile = () ->
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
        column_names: prepareArrayForPost(params, 'column_names')
        column_types: prepareArrayForPost(params, 'column_types')
        source_frames: "[\"#{opts.frameName}\"]")

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

  init = () ->
    attachUploadButtonListener()

  return {
    uploadAndPredict: uploadAndPredict
    getUploadedFrameId: get_id
  }
)()
$.extend(Upload: Upload)
