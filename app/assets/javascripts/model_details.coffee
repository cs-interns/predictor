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

    dom.append $('<h4>').html "<b>Model ID:</b> #{model.model_id.name}"
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
    plotXYscoringHistory('logloss-div', 4, 9, 13) if model.algo is 'deeplearning'
    plotXYscoringHistory('mse-div', 4, 7, 11) if model.algo is 'deeplearning'
    plotXYscoringHistory('drf-logloss-div', 3, 5, 11) if model.algo is 'drf'
    plotXYscoringHistory('drf-mse-div', 3, 4, 11) if model.algo is 'drf'
    plotHorizBarChart(model.output.variable_importances, 'drf-mse-div', 0, 2) if model.algo is 'drf'
    plotStandardCoefRatio() if model.algo is 'glm'


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
      name: coefratio.name
    }]

    Plotly.newPlot('bar-plot', dataset, {title: coefratio.name, showlegend: true})

  #------------------------------- Horiz Bar Chart -------------------------------
  plotHorizBarChart = (y_variable, div_id, x_index, y_index) ->
    bardiv = $('<div>')
    bardiv.attr({'id': div_id, 'align': 'center'})
    view.append bardiv

    variable = y_variable
    variabledata = variable.data

    blue_color = 'rgba(54, 162, 235, 1)'

    var_labels = []
    var_data = []
    var_labels.push(value) for value, c in variable.data[x_index].slice 0, -1
    var_data.push(value) for value in variable.data[y_index].slice 0, -1

    dataset = [{
      type: 'bar',
      x: var_data,
      y: var_labels,
      marker: {
        color: blue_color,
        width: 1
        },
      orientation: 'h',
      name: variable.name
    }]

    Plotly.newPlot(div_id, dataset, {title: variable.name, showlegend: true})


  #------------------------------- Logloss, MSE -------------------------------
  plotXYscoringHistory = (div_id, x_index, y_index, y_index_val) ->
    scoring_history = model.output.scoring_history
    epochs = scoring_history.data[x_index]
    variable = scoring_history.data[y_index]

    variablediv = $('<div>')
    variablediv.attr('id', div_id)
    view.append variablediv
    training_data_points = {
      x: epochs.slice(1, epochs.length),
      y: variable.slice(1, variable.length),
      mode: 'lines+markers',
      type: 'scatter'
      name: scoring_history.columns[y_index].description
    }
    variable_dataset = [training_data_points]
    y_axis_title = [scoring_history.columns[y_index].description]

    val_variable = scoring_history.data[y_index_val]
    unless val_variable is undefined
      validation_data_points = {
        x: epochs.slice(1, epochs.length),
        y: val_variable.slice(1, val_variable.length),
        mode: 'lines+markers',
        type: 'scatter'
        name: scoring_history.columns[y_index_val].description
      }
      variable_dataset.push validation_data_points
      y_axis_title.push scoring_history.columns[y_index_val].description


    variable_layout = {
      title: "Scoring History - Epochs vs #{scoring_history.columns[y_index].description.split(" ")[1]} Plot",
      showlegend: true,
      xaxis: {
        title: scoring_history.columns[x_index].description
      },
      yaxis: {
        title: y_axis_title.join(', ')
      }
    }

    Plotly.newPlot(div_id, variable_dataset, variable_layout)


  return {
    showModelDetail: showModelDetail
  }

)()
$.extend(ModelDetails: ModelDetails)
