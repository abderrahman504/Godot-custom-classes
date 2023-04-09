extends PanelContainer
class_name DrawerContainer

#This container should attach to its parent node, which is hopefully a control node.
#This container should only hold one control child of any type, including other containers.
#It can attach to any of four directions: north, south, east, west.
#It has an expand button called a Handle and two expansion modes: drag, or press.
	#In drag mode, the user must hold the button and drag the drawer out to expand it.
	#In press mode, the user just presses the expand button to toggle between open and closed.
#For simplicity, postpone drag mode and hide child control on drawer close


enum Direction {NORTH, SOUTH, EAST, WEST}
var handle: BaseButton
export (Direction) var openToDirection: int
export (bool) var attachFromInside: bool
export (Vector2) var handleSize: Vector2 = Vector2(70, 30)
export (bool) var isOpen: bool
var moving: bool = false


func _init():
	handle = Button.new()
	handle.icon = load("res://icon.png")
	handle.toggle_mode = false
	handle.icon_align = Button.ALIGN_CENTER
	handle.expand_icon = true
	add_child(handle)
	handle.connect("button_up", self, "on_handle_pressed")

func _ready():
	call_deferred("adjust_position", false)
	show_behind_parent = not attachFromInside
	


func _notification(what):
	if what != NOTIFICATION_SORT_CHILDREN:
		return
	
#	for c in get_children():
#		fit_child_in_rect(c, Rect2(Vector2.ZERO, rect_size))
	
	var handlePosition: Vector2 = Vector2(0.5*rect_size.x, 0.5*rect_size.y)
	match openToDirection:
		Direction.NORTH:
			handlePosition.y -= handleSize.y + 0.5*rect_size.y
			handlePosition.x -= 0.5*handleSize.x
		Direction.SOUTH:
			handlePosition.y += 0.5*rect_size.y
			handlePosition.x -= 0.5*handleSize.x
		Direction.EAST:
			handlePosition.x += 0.5*rect_size.x
			handlePosition.y -= 0.5*handleSize.y
		_:#WEST
			handlePosition.x -= 0.5*rect_size.x + handleSize.x
			handlePosition.y -= 0.5*handleSize.y 
	fit_child_in_rect(handle, Rect2(handlePosition, handleSize))


func adjust_position(smoothTrans: bool) -> void:
	if moving: return
	var parent: Control = get_parent()
	var targetPosition: Vector2
	var parentBottomY := parent.rect_size.y
	var parentTopY := 0
	var parentLeftX := 0
	var parentRightX := parent.rect_size.x
	
	
	match openToDirection:
		Direction.SOUTH:
			if attachFromInside:
				if isOpen:
					targetPosition = Vector2(rect_position.x, parentTopY)
				else:
					targetPosition = Vector2(rect_position.x, parentTopY - rect_size.y)
			else:
				if isOpen:
					targetPosition = Vector2(rect_position.x, parentBottomY)
				else:
					targetPosition = Vector2(rect_position.x, parentBottomY - rect_size.y)
			
		Direction.NORTH:
			if attachFromInside:
				if isOpen:
					targetPosition = Vector2(rect_position.x, parentBottomY - rect_size.y)
				else:
					targetPosition = Vector2(rect_position.x, parentBottomY)
			else:
				if isOpen:
					targetPosition = Vector2(rect_position.x, parentTopY - rect_size.y)
				else:
					targetPosition = Vector2(rect_position.x, parentTopY)
			
		Direction.WEST:
			if attachFromInside:
				if isOpen:
					targetPosition = Vector2(parentRightX - rect_size.x, rect_position.y)
				else:
					targetPosition = Vector2(parentRightX, rect_position.y)
			else:
				if isOpen:
					targetPosition = Vector2(parentLeftX - rect_size.x, rect_position.y)
				else:
					targetPosition = Vector2(parentLeftX, rect_position.y)
			
		_:#EAST
			if attachFromInside:
				if isOpen:
					targetPosition = Vector2(parentLeftX, rect_position.y)
				else:
					targetPosition = Vector2(parentLeftX - rect_size.x, rect_position.y)
			else:
				if isOpen:
					targetPosition = Vector2(parentRightX, rect_position.y)
				else:
					targetPosition = Vector2(parentRightX - rect_size.x, rect_position.y)
	
	if not smoothTrans:
		set_position(targetPosition)
		return
	var tween := create_tween()
	tween.tween_method(self, "set_position", rect_position, targetPosition, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	moving = true
	tween.tween_property(self, "moving", false, 0)


func on_handle_pressed() -> void:
	close() if isOpen else open()

func open() -> void:
	isOpen = true
	adjust_position(true)

func close() -> void:
	isOpen = false
	adjust_position(true)
