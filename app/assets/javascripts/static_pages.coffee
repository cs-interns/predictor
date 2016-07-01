$(document).ready ->
#----------------gets the list of all models------------------------
  $('#model-view').on 'click', ->
    $.getJSON 'http://139.59.249.87/3/Models', (result) ->
      console.log(result)
      modelElements = $.map result.models, (model, i) ->
        listItem = $('<li></li>')
        $('<a>' + model.model_id.name + '</a>' )
        .addClass('model')
        .attr('data-name', model.model_id.name)
        .attr('href', '#')
        .appendTo(listItem)
        return listItem
      $('.models-list').html(modelElements)

#--------------gets the cliked model details----------------------
$(document).ready ->
  $('div').on 'click', '.model', (e) ->
    e.preventDefault()
    $.getJSON 'http://139.59.249.87/3/Models/'+ $(this).data('name'), (result) ->
      console.log(result)
