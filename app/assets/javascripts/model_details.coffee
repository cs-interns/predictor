ModelDetails = (() ->

  showModelDetail = (model) ->
    console.log model
    if model.output.__meta.schema_name is "DeepLearningModelOutputV3"
      console.log "Model ID: #{model.model_id.name}"
      console.log "Algorithm used: #{model.algo_full_name}"
      console.log "Schema: #{model.output.__meta.schema_name}"

      output = model.output

      console.log "Model Category: #{output.model_category}"
      console.log "Training Metrics: #{output.training_metrics}"
      console.log "Validation Metrics: #{output.validation_metrics}"

      summary = output.model_summary
      sum_cols = summary.columns
      sum_data = summary.data
      console.log "#{summary.description}"
      column_name = []
      for col, i in sum_cols
        unless i is 0
          column_name.push col.description
          console.log sum_data[i]

      console.log column_name.join(',')



  return {
    showModelDetail: showModelDetail
  }

)()
$.extend(ModelDetails: ModelDetails)
