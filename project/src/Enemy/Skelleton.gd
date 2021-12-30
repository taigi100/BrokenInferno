extends KinematicBody2D

var knockback = Vector2.ZERO;
onready var stats = $Stats;
const EnemyDeathEffect = preload("res://src/Enemy/BatDeathEffect.tscn")
onready var playerDetectionZone = $PlayerDetectionZone
onready var sprite = $AnimatedSprite;
onready var hurtBox = $Hurtbox;
onready var softCol = $SoftCollision;
onready var wanderController = $WanderController
onready var animPlayer = $AnimationPlayer
export var ACCELERATION = 300;
export var MAX_SPEED = 50; 
export var FRICTION = 200;
export var TARGET_WANDER_RANGE = 2

enum {
	IDLE,
	WANDER,
	CHASE
}

var state = pick_random_state([IDLE, WANDER]);
var velocity = Vector2.ZERO;


func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta);
	knockback = move_and_slide(knockback);
	
	match state:
		IDLE:
			sprite.play("Fly");
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta);
			seek_player();
			
			if wanderController.get_time_left() == 0:
				update_wander_state();
		WANDER:
			seek_player();
			
			if wanderController.get_time_left() == 0:
				update_wander_state();
			
			sprite.play("Run");
			accelerate_towards(wanderController.target_position, delta);
			
			if global_position.distance_to(wanderController.target_position) <= TARGET_WANDER_RANGE:
				update_wander_state();
			
		CHASE:
			var player = playerDetectionZone.player;
			if player != null:
				sprite.play("Run");
				accelerate_towards(player.global_position, delta);
			else:
				state = IDLE;
	if softCol.is_colliding():
		velocity += softCol.get_push_vector() * delta * 400;
	velocity = move_and_slide(velocity);

func accelerate_towards(point, delta):
	var dir = global_position.direction_to(point)
	velocity = velocity.move_toward(dir * MAX_SPEED, ACCELERATION * delta);
	sprite.flip_h = velocity.x < 0;

func update_wander_state():
	sprite.play("Fly");
	state = pick_random_state([IDLE, WANDER])
	wanderController.start_timer(rand_range(1,3))

func seek_player():
	if playerDetectionZone.can_see_player():
		state = CHASE;

func wander_state():
	pass

func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage;
	knockback = area.knockback_vector * 120;
	hurtBox.create_hit_effect();
	hurtBox.start_invincibility(0.4);

func _on_Stats_no_health():
	var enemyDeathEffect = EnemyDeathEffect.instance();
	get_parent().add_child(enemyDeathEffect);
	enemyDeathEffect.global_position = global_position
	queue_free()

func pick_random_state(state_list):
	state_list.shuffle();
	return state_list.pop_front();


func _on_Hurtbox_invincibility_started():
	animPlayer.play("Start")


func _on_Hurtbox_invincibility_ended():
	animPlayer.play("Stop")
