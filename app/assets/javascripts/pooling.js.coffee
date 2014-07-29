$(document).on "ajax:complete", ".pool-share", (event, results) ->
	id = $(this).attr("id")
	shares = "#pool_"+id
	$(shares).html results.responseText

$(document).on "ajax:beforeSend", ".btn-check-status", ->
      $(this).hide()
      parent = $(this).parent()
      parent.find(".spinner").show "fast"

$(document).on "ajax:success", ".btn-check-status", ->
	$(this).show()
	parent = $(this).parent()
	parent.find(".spinner").hide "fast"
