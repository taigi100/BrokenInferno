extends PopupDialog


onready var player = get_node("/root/World/YSort/Player")

func _on_Resume_pressed():
	print("resume")
	get_tree().paused = false
	player.set_process_input(true)
	hide()

func _on_Quit_pressed():
	print("quit")
	get_tree().quit()
