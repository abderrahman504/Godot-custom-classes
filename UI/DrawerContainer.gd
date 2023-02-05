extends PanelContainer
class_name DrawerContainer

#This container should attach to its parent node, which is hopefully a control node.
#This container should only hold one control child of any type, including other containers.
#It can attach to any of four directions: north, south, east, west.
#It has an expand button called a Handle and two expansion modes: drag, or press.
	#In drag mode, the user must hold the button and drag the drawer out to expand it.
	#In press mode, the user just presses the expand button to toggle between open and closed.
#For simplicity, postpone drag mode and hide child control on drawer close


enum AttachDirection {NORTH, SOUTH, EAST, WEST}
var handle: BaseButton;
export (AttachDirection) var attachmentDirection: int
export (Vector2) var handleSize: Vector2 = Vector2(70, 30)


func _init():
	handle = Button.new()
	handle.icon = load("res://icon.png")
	handle.toggle_mode = true
	handle.icon_align = Button.ALIGN_CENTER
	handle.expand_icon = true
	add_child(handle)
	


func _ready():
	pass















func _notification(what):
	if what != NOTIFICATION_SORT_CHILDREN:
		return
	
	var handlePosition: Vector2 = Vector2(0.5*rect_size.x, 0.5*rect_size.y)
	match attachmentDirection:
		AttachDirection.NORTH:
			handlePosition.y -= handleSize.y + 0.5*rect_size.y
			handlePosition.x -= 0.5*handleSize.x
		AttachDirection.SOUTH:
			handlePosition.y += 0.5*rect_size.y
			handlePosition.x -= 0.5*handleSize.x
		AttachDirection.EAST:
			handlePosition.x += 0.5*rect_size.x
			handlePosition.y -= 0.5*handleSize.y
		_:#WEST
			handlePosition.x -= 0.5*rect_size.x + handleSize.x
			handlePosition.y -= 0.5*handleSize.y 
	fit_child_in_rect(handle, Rect2(handlePosition, handleSize))


