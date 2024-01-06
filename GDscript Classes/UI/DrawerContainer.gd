@tool
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
@export var openDirection: Direction
@export var attachFromInside: bool
var handleSize: Vector2 = Vector2(70, 30)

@export var HandleSize: Vector2:
	get: return handleSize
	set(value):
		handleSize = value
		notification(NOTIFICATION_RESIZED)

@export var isOpen: bool
@export_group("Transition")
@export var smoothTransition: bool = true
@export var transition: Tween.TransitionType = Tween.TRANS_CUBIC
@export var easing: Tween.EaseType = Tween.EASE_IN
@export var transitionTime: float = 0
var moving: bool = false


func _init():
	handle = Button.new()
	handle.icon = load("res://icon.png")
	handle.toggle_mode = false
	handle.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	handle.expand_icon = true
	add_child(handle)
	handle.connect("button_up", Callable(self, "on_handle_pressed"))

func _ready():
	call_deferred("adjust_position", smoothTransition)
	show_behind_parent = not attachFromInside

func _get_configuration_warnings():
	var warnings: Array[String] = []
	if not get_parent() is Control:
		warnings.append("This node needs to have a Control as a parent to work!")
	
	return warnings

func _notification(what):
	if (Engine.is_editor_hint()):
		update_configuration_warnings()
	
	#Initialize handle in the middle of the container
	var handlePosition: Vector2 = Vector2(0.5*size.x, 0.5*size.y)
	#Work out correct position for handle
	match openDirection:
		Direction.NORTH:
			handlePosition.y -= handleSize.y + 0.5*size.y
			handlePosition.x -= 0.5*handleSize.x
		Direction.SOUTH:
			handlePosition.y += 0.5*size.y
			handlePosition.x -= 0.5*handleSize.x
		Direction.EAST:
			handlePosition.x += 0.5*size.x
			handlePosition.y -= 0.5*handleSize.y
		_:#WEST
			handlePosition.x -= 0.5*size.x + handleSize.x
			handlePosition.y -= 0.5*handleSize.y 
	fit_child_in_rect(handle, Rect2(handlePosition, handleSize))


func adjust_position(smoothTrans: bool) -> void:
	if moving: return
	var parent: Control = get_parent()
	var targetPosition: Vector2
	var parentBottomY := parent.size.y
	var parentTopY := 0
	var parentLeftX := 0
	var parentRightX := parent.size.x
	
	match openDirection:
		Direction.SOUTH:
			if attachFromInside:
				if isOpen:
					targetPosition = Vector2(position.x, parentTopY)
				else:
					targetPosition = Vector2(position.x, parentTopY - size.y)
			else:
				if isOpen:
					targetPosition = Vector2(position.x, parentBottomY)
				else:
					targetPosition = Vector2(position.x, parentBottomY - size.y)
			
		Direction.NORTH:
			if attachFromInside:
				if isOpen:
					targetPosition = Vector2(position.x, parentBottomY - size.y)
				else:
					targetPosition = Vector2(position.x, parentBottomY)
			else:
				if isOpen:
					targetPosition = Vector2(position.x, parentTopY - size.y)
				else:
					targetPosition = Vector2(position.x, parentTopY)
			
		Direction.WEST:
			if attachFromInside:
				if isOpen:
					targetPosition = Vector2(parentRightX - size.x, position.y)
				else:
					targetPosition = Vector2(parentRightX, position.y)
			else:
				if isOpen:
					targetPosition = Vector2(parentLeftX - size.x, position.y)
				else:
					targetPosition = Vector2(parentLeftX, position.y)
			
		_:#EAST
			if attachFromInside:
				if isOpen:
					targetPosition = Vector2(parentLeftX, position.y)
				else:
					targetPosition = Vector2(parentLeftX - size.x, position.y)
			else:
				if isOpen:
					targetPosition = Vector2(parentRightX, position.y)
				else:
					targetPosition = Vector2(parentRightX - size.x, position.y)
	
	if not smoothTrans:
		set_position(targetPosition)
		return
	var tween := create_tween()
	tween.tween_method(Callable(self, "set_position"), position, targetPosition, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	moving = true
	tween.tween_property(self, "moving", false, 0)


func on_handle_pressed() -> void:
	close() if isOpen else open()

func open() -> void:
	isOpen = true
	adjust_position(smoothTransition)

func close() -> void:
	isOpen = false
	adjust_position(smoothTransition)
