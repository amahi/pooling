$(document).on "ajax:complete", ".pool-share", (event, results) ->
	id = $(this).attr("id")
	shares = "#pool_"+id
	console.log($(shares))
	console.log(results.responseText)
	$(shares).html results.responseText