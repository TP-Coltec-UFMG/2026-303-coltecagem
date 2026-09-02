extends CharacterBody2D
# A script for the train from the "Dodge!" minigame.


# Emitted if the player crashes.
signal crashed


# The space between each track.
const MOVEMENT_SPEED: float = 300.0


# The _velocity of the train.
var _velocity: Vector2 = Vector2.ZERO

# Stores whether or not controls for the train have been unlocked.
var _unlock_controls: bool = false


# The mainloop: Moves the train up and down the tracks on player input.
func _process( _delta ):
	if _unlock_controls:
		_velocity.y = 0.0
		if Input.is_action_pressed( "move_up" ):
			if position.y > 96:
				_velocity.y -= MOVEMENT_SPEED
		if Input.is_action_pressed( "move_down" ):
			if position.y < 392:
				_velocity.y += MOVEMENT_SPEED
		var collision = move_and_collide( _velocity * _delta )
		if collision:
			var body = collision.get_collider()
			# Only fail the minigame if the body has a signal (we use this to
			# differentiate the cars from the boundaries of the road)
			if body.has_signal( "crashed" ):
				emit_signal( "crashed" )
				body.unlock( false )

		# Rotate the player's car:
		if _velocity.y > 0.0:
			rotation_degrees = 30.0
		elif _velocity.y < 0.0:
			rotation_degrees = -30.0
		else:
			rotation_degrees = 0.0


# Unlocks the controls for the train.
func unlock( switch: bool = true ):
	_unlock_controls = switch
