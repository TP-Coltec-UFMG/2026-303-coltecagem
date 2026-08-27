extends CharacterBody2D

## Velocidade de movimento do personagem
@export var speed := 150.0

## Quanto o balanço "idle" varia aleatoriamente (efeito vivo)
@export var idle_wobble_amount := 3.0

@onready var anim_player: AnimationPlayer = $Pivot/AnimationPlayer
@onready var pivot: Node2D = $Pivot
@onready var arm_left: Node2D = $Pivot/Body/ArmLeft
@onready var arm_right: Node2D = $Pivot/Body/ArmRight
@onready var head: Node2D = $Pivot/Body/Head

var _facing := 1  # 1 = direita, -1 = esquerda


func _physics_process(_delta: float) -> void:
	var input_vector := Vector2.ZERO
	input_vector.x = Input.get_axis("move_left", "move_right")
	input_vector.y = Input.get_axis("move_up", "move_down")
	input_vector = input_vector.normalized()

	velocity = input_vector * speed
	move_and_slide()

	_update_animation(input_vector)
	_update_facing(input_vector)


func _update_animation(input_vector: Vector2) -> void:
	if input_vector.length() > 0.1:
		if anim_player.current_animation != "walk":
			anim_player.play("walk")
	else:
		if anim_player.current_animation != "idle":
			anim_player.play("idle")


func _update_facing(input_vector: Vector2) -> void:
	if input_vector.x > 0.1:
		_facing = -1
	elif input_vector.x < -0.1:
		_facing = 1
	# Inverte o Pivot (não o CharacterBody2D) pra não bagunçar colisão
	pivot.scale.x = _facing


## Chame esta função (ex: via Timer) se quiser adicionar variação
## procedural extra em cima da animação base, tipo olhar em volta.
func apply_random_idle_wobble() -> void:
	if anim_player.current_animation != "idle":
		return
	var tween := create_tween()
	tween.tween_property(
		head, "rotation", randf_range(-0.05, 0.05), 0.6
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
