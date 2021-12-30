extends MarginContainer



func _on_PlayButton_pressed():
	get_tree().change_scene("res://src/World.tscn")


func _on_ExitButton_pressed():
	get_tree().quit()
