current_idx=0

vpl=0
target=0
timer=null

animate=(x)->
	target=x
	return if timer
	timer=setInterval ->
		if vpl>target
			vpl-=Math.min(30,vpl-target)
		else if vpl==target
			clearInterval(timer)
			timer=null
		else#if vpl<target
			vpl+=Math.min(30,target-vpl)
		viewing_pane.style.left="#{vpl}px"
	,10

OpenImage=(idx)->
	current_idx=parseInt(idx)
	image_id="image-#{current_idx}"
	#viewing_pane.style.backgroundImage="url('#{document.getElementById(image_id).src}')"
	animate(idx*-1*viewing_width)


@move_left=->
	OpenImage(if current_idx is 0 then image_count-1 else current_idx-1)
@move_right=->
	OpenImage(if current_idx is image_count-1 then 0 else current_idx+1)


$=(x)->document.getElementById(x)

@onkeydown=(evt)=>
	evt||=@event
	if evt.keyCode==39#right
		move_right()
	else if evt.keyCode==37#left
		move_left()

@onload= =>
	@image_count=parseInt($('image-count').innerHTML)
	vc=$('viewing-container')
	@viewing_width=vc.offsetWidth||vc.clientWidth
	str="#{@viewing_width}px"
	vc.style.height=str
	x=0
	@viewing_pane=$('viewing-pane')
	for node in @viewing_pane.childNodes
		if node.style?
			node.style.width=str
			node.style.left="#{x}px"
			x+=viewing_width
	OpenImage(0)