extends Path2D
# A scene for paths which spawn enemies in the shoot 'em up minigame.


# A duplicate of the "exploded" signal in the `ShooterBadGuy` node.
signal exploded( location )

# Which scene to use for the enemies spawned on the path.
@export var _enemy: PackedScene


# Spawns an enemy on the path.
func spawn_enemy():
	var enemy = _enemy.instantiate()
	# Connect the enemy's "exploded" signal to this EnemyPath's signal.
	enemy.exploded.connect( _on_enemy_exploded )
	add_child( enemy )


# Passes up the `ShooterBadGuy` "exploded" signal to the minigame.
func _on_enemy_exploded( location ):
	emit_signal( "exploded", location )
