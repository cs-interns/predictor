ModelDetails = (() ->

  showModelDetail = (model, domy) ->
    dom = domy.children().first()
    console.log dom
    console.log model
    ###################### MODEL SUMMARY ######################
    dom.empty()

    dom.append $('<h4>').text "Model ID: #{model.model_id.name}"
    dom.append $('<p>').text "Algorithm used: #{model.algo_full_name}"
    dom.append $('<p>').text "Schema: #{model.output.__meta.schema_name}"

    output = model.output

    dom.append $('<p>').text "Model Category: #{output.model_category}"

    # not yet implemented. Depends on the algorithm used

    summary = output.model_summary
    sum_cols = summary.columns
    sum_data = summary.data

    showConfusionMatrix(output,dom) if model.algo is "deeplearning" or model.algo is "drf"

    # show description of model summary
    dom.append $('<h5>').text "Model Summary #{summary.description}"

    tbl = $('<table>')
    tbl.addClass("responsive-table striped")
    tbdy = $('<tbody>')
    tr = $('<tr>')

    column_name = []
    for col, c in sum_cols
     unless c is 0
       column_name.push col.description
       td = $('<td>')
       td.html("#{col.description}")
       tr.append(td)
    tbdy.append(tr)
    console.log column_name.join('\t')
    for row, r in sum_data
     row_data = []
     trr = $('<tr>')
     for col, c in sum_cols
       unless c is 0 or typeof sum_data[c][r] is 'undefined'
         if typeof sum_data[c][r] is 'number'
           row_data.push parseFloat(sum_data[c][r]).toFixed(2)
           celldata = parseFloat(sum_data[c][r]).toFixed(2)
           td = $('<td>')
           td.html("#{celldata}")
           trr.append(td)
         else
           row_data.push sum_data[c][r]
           td = $('<td>')
           td.html("#{sum_data[c][r]}")
           trr.append(td)
     tbdy.append(trr)
     console.log row_data.join('\t')

     tbl.append(tbdy)
     dom.append(tbl)

  showConfusionMatrix = (output,dom)->
    training_cm = output.training_metrics.cm.table
    training_cm_col = training_cm.columns
    training_cm_data = training_cm.data

    # show confusion matrix of model
    dom.append $('<h5>').text "Training Metrics - Confusion Metrics"
    trainingCmTable = $('<table>')
    trainingCmTable.addClass("responsive-table striped")
    trainingCmHeaders = $('<thead>')
    trainingCmBody = $('<tbody>')
    rowHead = training_cm_col.slice(0,-2)
    bufferRowHead = {description:"Total"}
    rowHead.push bufferRowHead
    console.log rowHead
    training_cm_data.unshift rowHead
    bufferCol = {description:" "}
    training_cm_col.unshift(bufferCol)
    for col in training_cm_col
      trainingCmHeaders.append("<th>#{col.description}</th>")
    trainingCmHeaders.appendTo(trainingCmTable)
    console.log training_cm_col
    for data, r in training_cm_data[0]
      trainingCmRow = $('<tr>')
      for cols, c in training_cm_data
        if c == 0
          trainingCmRow.append("<td><b>#{cols[r].description}</b></td>")
        else
          trainingCmRow.append("<td>#{cols[r]}</td>")
      trainingCmRow.appendTo(trainingCmBody)
    trainingCmTable.append(trainingCmBody)

    dom.append(trainingCmTable)


  return {
    showModelDetail: showModelDetail
  }

)()
$.extend(ModelDetails: ModelDetails)
