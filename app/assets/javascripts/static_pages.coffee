# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$(document).ready ->
  $('#model-view').on 'click', (event) =>
    $.getJSON 'http://139.59.249.87/3/Models', (result) =>
      console.log(result)
      modelElements = $.map result.models, (model, i) =>
        listItem = $('<li></li>')
        $('<a>' + model.model_id.name + '</a>' ).addClass('model')
          .attr('data-name', model.model_id.name)
          .attr('href', '#')
          .appendTo(listItem)
        return listItem
      $('.models-list').html(modelElements)

  $('div').on 'click', '.model', (e) =>
    e.preventDefault()
    key = $(this).data('name')
    $.getJSON 'http://139.59.249.87/3/Models/'+ key, (result) =>
      console.log(result)

# <!Doctype html>
# <html>
#   <body>
#     <button id="model-view">View All Models</button>
#     <div class="models-list"></div>
#   </body>
# </html>
