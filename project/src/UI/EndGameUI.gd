extends PopupDialog


onready var player = get_node("/root/World/YSort/Player")
onready var label = $CenterContainer/VBoxContainer/Label
var stats = PlayerStats;

func set_label(text):
	label.set_text(text)

func _on_Resume_pressed():
	#Restart
	stats.health = stats.max_health
	get_tree().reload_current_scene()
	get_tree().paused = false
	player.set_process_input(true)
	hide()

func _on_Quit_pressed():
	get_tree().quit()
