class_name Projectile2D
extends CharacterBody2D
# A generic class for in-game projectiles of arbitrary speed, direction,
# shape, and size.


# A signal to indicate that a collision has occurred.  `data` is a
# `KinematicCollision2D` used to provide the minigame with information about
# the collision.
signal collided( data )

# The rate of speed of the projectile, in pixels.
@export var _speed: float = 0.0:
	set(new_speed):
		_speed = new_speed
		_update_velocity()

# The direction that the projectile faces, in degrees.
@export var _direction: float = 0.0:
	set(new_direction):
		_direction = new_direction
		_update_velocity()

# The rate of spin for the projectile in degrees.
@export var spin_degrees: float = 0.0

# If true, the projectile will remove itself upon detecting a collision.
@export var _disappear_on_collision: bool = true

# The current velocity of the projectile.
var _velocity: Vector2


# Initializes the projectile by setting its linear velocity based on the
# speed & direction parameters.
func _init():
	_update_velocity()


# Recalculates the projectile's linear velocity based on the `_speed` &
# `_direction`.
func _update_velocity():
	_velocity = Vector2( _speed, 0 ).rotated( deg_to_rad( _direction ) )


# The default process will move the projectile in space and, if applicable,
# spin it.
func _physics_process( delta ):
	var collision = move_and_collide( _velocity * delta )

	# If a collision is detected, signal this.  If applicable, the projectile
	# will also disappear.
	if collision:
		emit_signal( "collided", collision )
		if _disappear_on_collision:
			queue_free()

	if spin_degrees != 0.0:
		$Sprite.rotation_degrees += spin_degrees * delta


# Sets the projectile's speed and recalculates its linear velocity.
# Kept as an explicit method since other scripts call it directly.
func set_speed( new_speed: float ):
	_speed = new_speed


func get_speed() -> float:
	return _speed


# Sets the projectile's direction and recalculates its linear velocity.
func set_direction( new_direction: float ):
	_direction = new_direction


func get_direction() -> float:
	return _direction


func set_spin( new_spin: float ):
	spin_degrees = new_spin


func get_spin() -> float:
	return spin_degrees


# Disappear when leaving the screen.
func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
