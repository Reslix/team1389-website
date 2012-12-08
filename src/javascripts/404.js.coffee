$= (x)->document.getElementById(x)
search_engine_regex=/google.com|bing.com|yahoo.com|duckduckgo/
our_site_regex=/^http(s?):\/\/(www.)?team1389(.github)?.com\//
@onload= =>
	$('submitting-report').innerHTML="Submitting report..."
	ref=document.referrer
	if search_engine_regex.test(ref)
		$('extra-info').innerHTML="It appears that you were directed here by a search engine."
	else if our_site_regex.test(ref)
		$('extra-info').innerHTML="It appears that you were directed here by a broken link on our website."
	else
		$('extra-info').innerHTML="That's all we know."
	$('404-form-target').onload= ->
		$('submitting-report').innerHTML="A report has been submitted and we will work to rectify the problem."
	$('404-page-url').value=window.location.href
	$('404-referrer-url').value=ref
	func=$('404-form').submit
	$('404-submit-field').name="submit"
	func.call($('404-form'))