ModelDetails = (() ->
  model = undefined
  view = undefined

  showModelDetail = (the_model, domy) ->
    model = the_model
    dom = domy.children().first()
    view = dom
    console.log model
    ###################### MODEL SUMMARY ######################
    dom.empty()

    dom.append $('<h4>').text "Model ID: #{model.model_id.name}"
    dom.append $('<p>').text "Algorithm used: #{model.algo_full_name}"
    dom.append $('<p>').text "Schema: #{model.output.__meta.schema_name}"

    output = model.output

    dom.append $('<p>').text "Model Category: #{output.model_category}"

    # not yet implemented. Depends on the algorithm used
    console.log "Training Metrics: #{output.training_metrics}"
    console.log "Validation Metrics: #{output.cross_validation_metrics}"

    summary = output.model_summary
    sum_cols = summary.columns
    sum_data = summary.data

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
    plotStandardCoefRatio() if model.algo is 'glm'
    plotLogLoss() if model.algo is 'deeplearning'


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
      orientation: 'h'
    }]

    Plotly.newPlot('bar-plot', dataset, title: coefratio.description)

  plotLogLoss = () ->
    scoring_history = model.output.scoring_history
    epochs = scoring_history.data[4]
    logloss = scoring_history.data[9]

    loglossdiv = $('<div>')
    loglossdiv.attr('id', 'logloss-plot')
    view.append loglossdiv
    data_points = {
      x: epochs.splice(1, epochs.length),
      y: logloss.splice(1, logloss.length),
      type: 'lines+markers'
    }
    logloss_layout = {
      title: "Scoring History - #{scoring_history.columns[9].description}"
      xaxis: {
        title: scoring_history.columns[4].description
      },
      yaxis: {
        title: scoring_history.columns[9].description
      }
    }

    Plotly.newPlot('logloss-plot', [data_points], logloss_layout)

  return {
    showModelDetail: showModelDetail
  }

)()
$.extend(ModelDetails: ModelDetails)
