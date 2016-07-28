ModelDetails = (() ->
  model = undefined
  view = undefined

  showModelDetail = (the_model, domy) ->
    model = the_model
    dom = domy.children().first()
    view = dom
    ###################### MODEL SUMMARY ######################
    dom.empty()

    output = model.output
    summary = output.model_summary
    sum_cols = summary.columns
    sum_data = summary.data

    dom.append $("<h4><b>Details for #{model.model_id.name} model</b></h4>")
    
    #PARAMETERS
    dom.append $("<p>
      <b>Algorithm used:</b> #{model.algo_full_name}<br>
      <b>Schema:</b> #{model.output.__meta.schema_name}<br>
      <b>Model Category:</b> #{output.model_category}
    </p>")

    #MODEL DESCRIPTION SUMMARY
    if summary.description
      dom.append $("<p>#{summary.name} (#{summary.description})<p>".toUpperCase())
    else
      dom.append $("<p>#{summary.name}</p>".toUpperCase())

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
    tbl.append(tbdy)
    dom.append(tbl)

    # show confusion matrix
    if model.algo is "drf" or model.algo is "deeplearning"
      unless output.training_metrics is null
        training_cm = output.training_metrics.cm.table
        showConfusionMatrix("Training Metrics",training_cm,dom)
        dom.append $('<br>')
      unless output.validation_metrics is null
        validation_cm = output.validation_metrics.cm.table
        showConfusionMatrix("Validation Metrics",validation_cm,dom)
        dom.append $('<br>')
      unless output.cross_validation_metrics is null
        cross_validation_cm = output.cross_validation_metrics.cm.table
        showConfusionMatrix("Cross Validation Metrics",cross_validation_cm,dom)
        dom.append $('<br>')

    

    plotStandardCoefRatio() if model.algo is 'glm'
    plotLogLoss() if model.algo is 'deeplearning'
    plotMSE() if model.algo is 'deeplearning'


  plotStandardCoefRatio = () ->
    bardiv = $('<div>')
    # bardiv.attr({'width':0, 'height':0})
    bardiv.attr('id', 'bar-plot')
    view.append bardiv

    coefratio = model.output.standardized_coefficient_magnitudes
    coefratiodata = coefratio.data

    pos_color = 'rgba(54, 162, 235, 1)' # Blue
    neg_color = 'rgba(255, 99, 132, 1)' # Red

    coef_labels = []
    coef_data = []
    coef_color = []
    coef_labels.push("#{value} (#{coefratio.data[2][c]})") for value, c in coefratio.data[0].slice 0, -1
    coef_data.push(value) for value in coefratio.data[1].slice 0, -1


    for value in coefratio.data[2].slice 0, -1
        if value == 'NEG'
          coef_color.push(neg_color)
        else
          if value == 'POS'
            coef_color.push(pos_color)

    dataset = [{
      type: 'bar',
      x: coef_data,
      y: coef_labels,
      marker: {
        color: coef_color,
        width: 1
        },
      orientation: 'h',
      name: coefratio.description
    }]

    Plotly.newPlot('bar-plot', dataset, {title: coefratio.description, showlegend: true})

  #---------------------------------- LogLoss ----------------------------------
  plotLogLoss = () ->
    scoring_history = model.output.scoring_history
    epochs = scoring_history.data[4]
    logloss = scoring_history.data[9]

    loglossdiv = $('<div>')
    loglossdiv.attr('id', 'logloss-plot')
    view.append loglossdiv
    training_data_points = {
      x: epochs.slice(1, epochs.length),
      y: logloss.slice(1, logloss.length),
      type: 'lines+markers',
      name: scoring_history.columns[9].description
    }
    logloss_dataset = [training_data_points]
    y_axis_title = [scoring_history.columns[9].description]

    val_logloss = scoring_history.data[13]
    unless val_logloss is undefined
      validation_data_points = {
        x: epochs.slice(1, epochs.length),
        y: val_logloss.slice(1, val_logloss.length),
        type: 'lines+markers',
        name: scoring_history.columns[13].description
      }
      logloss_dataset.push validation_data_points
      y_axis_title.push scoring_history.columns[13].description


    logloss_layout = {
      title: "Scoring History - Epochs vs LogLoss Plot",
      showlegend: true,
      xaxis: {
        title: scoring_history.columns[4].description
      },
      yaxis: {
        title: y_axis_title.join(', ')
      }
    }

    Plotly.newPlot('logloss-plot', logloss_dataset, logloss_layout)

  #---------------------------------- MSE ----------------------------------
  plotMSE = () ->
    scoring_history = model.output.scoring_history
    epochs = scoring_history.data[4]
    mse = scoring_history.data[7]

    msediv = $('<div>')
    msediv.attr('id', 'mse-plot')
    view.append msediv
    training_data_points = {
      x: epochs.slice(1, epochs.length),
      y: mse.slice(1, mse.length),
      type: 'lines+markers',
      name: scoring_history.columns[7].description
    }
    mse_dataset = [training_data_points]
    y_axis_title = [scoring_history.columns[7].description]

    val_mse = scoring_history.data[11]
    unless val_mse is undefined
      validation_data_points = {
        x: epochs.slice(1, epochs.length),
        y: val_mse.slice(1, val_mse.length),
        type: 'lines+markers',
        name: scoring_history.columns[11].description
      }
      mse_dataset.push validation_data_points
      y_axis_title.push scoring_history.columns[11].description


    mse_layout = {
      title: "Scoring History - Epochs vs LogLoss Plot",
      showlegend: true,
      xaxis: {
        title: scoring_history.columns[4].description
      },
      yaxis: {
        title: y_axis_title.join(', ')
      }
    }

    Plotly.newPlot('mse-plot', mse_dataset, mse_layout)



  showConfusionMatrix = (title,cm,dom)->
    cm_col = cm.columns
    cm_data = cm.data

    dom.append $('<h5>').text "#{title}"+ " - " +"#{cm.name}"
    trainingCmTable = $('<table>')
    trainingCmTable.addClass("responsive-table striped")
    trainingCmHeaders = $('<thead>')
    trainingCmBody = $('<tbody>')
    rowHead = cm_col.slice(0,-2)
    bufferRowHead = {description:"Total"}
    rowHead.push bufferRowHead
    cm_data.unshift rowHead
    bufferCol = {description:" "}
    cm_col.unshift(bufferCol)
    for col in cm_col
      trainingCmHeaders.append("<th>#{col.description}</th>")
    trainingCmHeaders.appendTo(trainingCmTable)
    for data, r in cm_data[0]
      trainingCmRow = $('<tr>')
      for cols, c in cm_data
        if c is 0
          trainingCmRow.append("<td><b>#{cols[r].description}</b></td>")
        else if c-1 == r
          trainingCmRow.append("<td class = 'yellow'>#{cols[r]}</td>")
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
