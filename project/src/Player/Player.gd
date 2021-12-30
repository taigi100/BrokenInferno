extends KinematicBody2D

var velocity = Vector2.ZERO;
const MAX_SPEED = 80;
const ACCELERATION = 750;
const FRICTION = 500;
const ROLL_SPEED = MAX_SPEED * 1.5;

const PlayerHurtSound = preload("res://src/Player/PlayerHurtSound.tscn")

enum {
	MOVE,
	ROLL,
	ATTACK
}

var state = MOVE;
var roll_vector = Vector2.LEFT;
var stats = PlayerStats;

onready var animationTree = $AnimationTree;
onready var animationState = animationTree.get("parameters/playback");
onready var swordHitBox = $HitboxPivot/SwordHitbox
onready var hurtBox = $Hurtbox
onready var blinkAnimPlayer = $BlinkAnimationPlayer
onready var pauseUI = get_node("/root/World/CanvasLayer/PauseMenu")
onready var endgameUI = get_node("/root/World/CanvasLayer/EndGameMenu")

func _ready():
	randomize();
	stats.connect("no_health", self, "die");
	animationTree.active = true;
	swordHitBox.knockback_vector = roll_vector;

func die():
	get_tree().paused = true
	self.set_process_input(false)
	endgameUI.set_label("You've lost!")
	endgameUI.popup()

func win():
	get_tree().paused = true
	self.set_process_input(false)
	endgameUI.set_label("You've won!")
	endgameUI.popup()

func _physics_process(delta):
	
	match state:
		MOVE:
			move_state(delta);
		ROLL:
			roll_state(delta);
		ATTACK:
			attack_state(delta);
	#Just for development ease
	if Input.is_action_just_pressed("Exit"):
		get_tree().quit(0)
	if Input.is_action_just_pressed("Pause"):
		get_tree().paused = true
		self.set_process_input(false)
		pauseUI.popup()

func move_state(delta):
	var input_vector = Vector2.ZERO;	
	input_vector.x = Input.get_action_strength("ui_right")-Input.get_action_strength("ui_left");
	input_vector.y = Input.get_action_strength("ui_down")-Input.get_action_strength("ui_up");
	input_vector = input_vector.normalized();
	
	if input_vector != Vector2.ZERO:
		roll_vector = input_vector;
		swordHitBox.knockback_vector = roll_vector;
		animationTree.set("parameters/Idle/blend_position", input_vector);
		animationTree.set("parameters/Run/blend_position", input_vector);
		animationTree.set("parameters/Attack/blend_position", input_vector);
		animationTree.set("parameters/Roll/blend_position", input_vector);
		animationState.travel("Run");
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta);
	else:
		animationState.travel("Idle");
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta);
	
	velocity = velocity.clamped(MAX_SPEED);
	move();
	
	if Input.is_action_just_pressed("attack"):
		state = ATTACK;
		
	if Input.is_action_just_pressed("Roll"):
		state = ROLL;

# warning-ignore:unused_argument
func attack_state(delta):
	velocity = Vector2.ZERO;
	animationState.travel("Attack");

func roll_state(_delta):
	velocity = roll_vector * ROLL_SPEED;
	animationState.travel("Roll");
	move();

func attack_animation_finished():
	state = MOVE;

func roll_animation_finished():
	state = MOVE;

func move():
	velocity = move_and_slide(velocity);


func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage ;
	hurtBox.start_invincibility(0.6);
	hurtBox.create_hit_effect();
	var playerHurtSound = PlayerHurtSound.instance();
	get_tree().current_scene.add_child(playerHurtSound)


func _on_Hurtbox_invincibility_started():
	blinkAnimPlayer.play("Start");


func _on_Hurtbox_invincibility_ended():
	blinkAnimPlayer.play("Stop");
