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
    console.log "Training Metrics: #{output.training_metrics}"
    console.log "Validation Metrics: #{output.validation_metrics}"

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


  return {
    showModelDetail: showModelDetail
  }

)()
$.extend(ModelDetails: ModelDetails)
