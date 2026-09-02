extends CharacterBody2D
# A ball threatening the goalie's turf.


# This signal is emitted when the ball reaches the goal.
signal passed_goal


# The ball's linear speed.
const BASE_SPEED: float = 400.0


# A boolean that unlocks movement.
var moving: bool = false

# This boolean is set to `true` when the ball has passed the goal or gone
# out-of-bounds, so that it doesn't spam the "passed_goal" signal.
var _has_passed_goal: bool = false

# The ball's _velocity.  This value is constant unless the ball has moved into
# the goal.
var _velocity: Vector2 = Vector2(-BASE_SPEED, 0.0)

# The ball's sprite.
@onready var sprite: Sprite2D = $Sprite


# The ball's physics process.
func _physics_process(delta):
	if moving:
		# Move the ball according to its `_velocity`, checking for collisions
		# as we go.
		var collision: KinematicCollision2D = move_and_collide(_velocity * delta,
				true)
		# Bounce off of anything we collide with.
		if collision:
			_velocity = _velocity.bounce(collision.get_normal())
		sprite.rotation_degrees += _velocity.length_squared() * \
				(-delta if _velocity.y > 0 else delta)
	if _has_passed_goal:
		# If the ball is has reached the goal, it will slow to a stop.
		_velocity = _velocity.move_toward(Vector2.ZERO, BASE_SPEED * delta)
	else:
		# If the ball moves past the goal, signal the game that the player
		# has lost.
		if global_position.x < 100.0:
			emit_signal("passed_goal")
			_has_passed_goal = true


# How to draw the ball.  This function only really exists because Godot doesn't
# have a default node for drawing a circle.
#func _draw():
#	draw_circle(Vector2.ZERO, 10.0, Color.WHITE)


# Starts the ball, having it pick a direction and then start moving.
func start():
	moving = true
