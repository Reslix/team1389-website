$= (x)->document.getElementById(x)
search_engine_regex=/google.com|bing.com|yahoo.com|duckduckgo/
our_site_regex=/^http(s?):\/\/(www.)?team1389(.github)?.com\//
@onload= =>
	ref=document.referrer
	if ref==""
		$('extra-info').innerHTML="That's all we know."
	else if search_engine_regex.test(ref)
		$('extra-info').innerHTML="It appears that you were directed here by a search engine. We have recorded the problem and will work to rectify it."
	else if our_site_regex.test(ref)
		$('extra-info').innerHTML="It appears that you were directed here by a broken link on our website. We have recorded the problem and will work to rectify it."
	else
		$('extra-info').innerHTML="We have recorded the problem and will work to rectify it."