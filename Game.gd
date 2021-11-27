# This defines the global Game object

extends Node

var _time = 0

# use Game.dialog to check if a dialog is open (so you can ignore input)
var _dialog = null

# Call Game.shake_camera() to shake the camera
var _shaking = false
var _shaking_timer

func _ready():
	# load the saywhat dialog file
	DialogueManager.resource = preload("res://dialog.tres")
	DialogueManager.game_state = Game
	_shaking_timer =  Timer.new()
	_shaking_timer.connect("timeout",self,"_stop_shake")
	add_child(_shaking_timer)

func _process(delta):
	_time += delta
	if _shaking:
		var camera = _get_current_camera()
		var m = sin(_time* 100) * 0.1
		camera.transform.origin.x += m

# show a SayWhat dialog
func show_dialog(id: String) -> void:
	_dialog = yield(DialogueManager.get_next_dialogue_line(id), "completed")
	if _dialog != null:
		var balloon = ResourceLoader.load("res://scenes/Dialog.tscn").instance()
		balloon.handle(_dialog)
		add_child(balloon)
		show_dialog(yield(balloon, "dialog_actioned"))

# load anotehr scene
func load_scene(scene_name):
	print("Not done, but this would show a scene: ", scene_name)

# find the current viewport camera
func _get_current_camera():
	 return get_node("/root").get_viewport().get_camera()

# make the camera shake, then stop in a second
# args is an array because that is how functions come from saywhat (called in dialog)
func shake_camera(args):
	var shake_time = 2
	if not args.empty():
		shake_time = float(args[0])
	_shaking = true
	_shaking_timer.set_wait_time(shake_time)
	_shaking_timer.start()
	
# called on timer to end shake
func _stop_shake():
	_shaking = false

# manage game-wide input
# this is very simple camera, normally you would put stuff in _process
# and have a point that the camera moves towards
func _input(event):
	# if there is no dialog, use keys to move camera
	if _dialog == null:
		var camera = _get_current_camera()
		
		if event.is_action_pressed('ui_up'):
			camera.transform.origin.z -= 1

		if event.is_action_pressed('ui_down'):
			camera.transform.origin.z += 1
		
		if event.is_action_pressed('ui_left'):
			camera.transform.origin.x -= 1

		if event.is_action_pressed('ui_right'):
			camera.transform.origin.x += 1

