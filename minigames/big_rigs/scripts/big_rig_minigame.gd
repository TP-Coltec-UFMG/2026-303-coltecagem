extends Minigame
# A script for the "Race that Rig!" minigame.


@onready var _day_sky = load("res://minigames/shared/scenes/background/blue_sky.tscn")
@onready var _night_sky = load("res://minigames/shared/scenes/background/night_sky.tscn")


func _ready():
	var sky: SkyBackground
	# Randomly choose between a daytime sky or a nighttime sky.
	if randi() & 1:
		sky = _day_sky.instantiate()
	else:
		sky = _night_sky.instantiate()
	sky.show_behind_parent = true
	add_child(sky)


# Mainloop for the minigame.  Moves the second player rig.
func _process( delta ):
	if _unlock_controls:
		if $RigPath/Rig2.progress_ratio < 1.0:
			$RigPath/Rig2.progress_ratio += 0.25 * delta


# Upon starting, enable movement in the rigs.
func start():
	_unlock_controls = true
	$RigPath/Rig1.allow_movement = true


# Rig1 has reached the end of the course and the player therefore wins.
func _on_Rig1_finished():
	emit_signal( "won" )
	_unlock_controls = false
	$TextureRect.show()
