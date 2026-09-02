extends Sprite2D
# A script for the clouds in the "Don't Fall Down!" minigame.


# A multiplier for how fast the cloud should move relative to the wind speed.
@export var _speed_multiplier: float = 1.0


# Blows the cloud along at the given wind speed.
func blow( wind: float ):
	position.x += wind * _speed_multiplier
