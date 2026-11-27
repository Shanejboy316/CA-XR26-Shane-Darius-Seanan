extends Node3D

const POINTER = preload("res://addons/godot-xr-tools/functions/function_pointer.tscn")
const TARGET_LAYER := 1 << 20 # Godot physics layer 21.

@onready var board = $WorldAnchor/BoardViewport/RoutingBoard
@onready var targets: Array[StaticBody3D] = [$WorldAnchor/LeftTarget, $WorldAnchor/RightTarget]


func _ready() -> void:
	var xr := XRServer.primary_interface
	var using_xr := xr != null and xr.is_initialized()
	get_viewport().use_xr = using_xr
	get_viewport().physics_object_picking = not using_xr
	set_process(using_xr)

	for i in targets.size():
		if using_xr:
			targets[i].connect("pointer_event", _on_pointer.bind(i))
		else:
			targets[i].input_event.connect(_on_mouse.bind(i))
	board.board_updated.connect(_update_targets)
	_update_targets()

	if using_xr:
		$XROrigin3D/XRCamera3D.make_current()
		$WorldAnchor.hide()
		_add_pointer(&"left_hand")
		_add_pointer(&"right_hand")
		if xr.has_signal("pose_recentered"):
			xr.connect("pose_recentered", set_process.bind(true))
	else:
		$DesktopCamera.make_current()


func _process(_delta: float) -> void:
	# Place the station once when head tracking starts, or when the player recentres.
	var head := XRServer.get_tracker(&"head") as XRPositionalTracker
	if head == null:
		return
	var pose := head.get_pose(&"default")
	if pose == null or pose.tracking_confidence == XRPose.XR_TRACKING_CONFIDENCE_NONE:
		return
	var head_transform: Transform3D = $XROrigin3D.global_transform * pose.get_adjusted_transform()
	$WorldAnchor.global_position = head_transform.origin
	$WorldAnchor.global_rotation = Vector3(0, head_transform.basis.get_euler().y, 0)
	$WorldAnchor.show()
	set_process(false)


func _add_pointer(hand: StringName) -> void:
	var controller := XRController3D.new()
	controller.name = hand
	controller.tracker = hand
	controller.pose = &"aim"
	controller.show_when_tracked = true
	$XROrigin3D.add_child(controller)

	var pointer := POINTER.instantiate() as XRToolsFunctionPointer
	pointer.distance = 4.0
	pointer.collision_mask = TARGET_LAYER
	pointer.laser_length = XRToolsFunctionPointer.LaserLength.COLLIDE
	pointer.enabled = controller.get_has_tracking_data()
	controller.tracking_changed.connect(pointer.set_enabled)
	controller.add_child(pointer)


func _update_targets() -> void:
	for i in targets.size():
		var caption: String = board.get_target_text(i)
		var target := targets[i]
		target.get_node("Label").text = caption
		target.visible = not caption.is_empty()
		target.collision_layer = TARGET_LAYER if target.visible else 0


func _on_pointer(event: XRToolsPointerEvent, index: int) -> void:
	if event.event_type == XRToolsPointerEvent.Type.PRESSED and targets[index].is_visible_in_tree():
		board.choose_target(index)


func _on_mouse(_camera: Node, event: InputEvent, _position: Vector3, _normal: Vector3, _shape: int, index: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		board.choose_target(index)
