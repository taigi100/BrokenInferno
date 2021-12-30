extends Node2D

onready var sprite = $AnimatedSprite
onready var player = get_node("/root/World/YSort/Player")



func _on_Hurtbox_area_entered(area):
	sprite.play()
	yield(get_tree().create_timer(1.0), "timeout")
	player.win()
