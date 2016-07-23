ModelDetails = (() ->

  showModelDetail = (model) ->
    console.log model
    console.log "Model ID: #{model.model_id.name}"
    console.log "Algorithm used: #{model.algo_full_name}"
    console.log "Schema: #{model.output.__meta.schema_name}"

    output = model.output

    console.log "Model Category: #{output.model_category}"
    console.log "Training Metrics: #{output.training_metrics}"
    console.log "Validation Metrics: #{output.validation_metrics}"


    ###################### MODEL SUMMARY ######################
    summary = output.model_summary
    sum_cols = summary.columns
    sum_data = summary.data

    # show description of model summary
    console.log "#{summary.description}"

    for col, c in sum_cols
      unless c is 0
        column_data = sum_data[c].join('\t')
        console.log "#{col.description} | #{column_data}"


    # column_name = []
    # for col, c in sum_cols
    #   unless c is 0
    #     column_name.push col.description
    # console.log column_name.join('\t')
    # for row, r in sum_data
    #   row_data = []
    #   for col, c in sum_cols
    #     unless c is 0
    #       if typeof sum_data[c][r] is 'number'
    #         row_data.push parseFloat(sum_data[c][r]).toFixed(2)
    #       else
    #         row_data.push sum_data[c][r]
    #   console.log row_data.join('\t')


  return {
    showModelDetail: showModelDetail
  }

)()
$.extend(ModelDetails: ModelDetails)
