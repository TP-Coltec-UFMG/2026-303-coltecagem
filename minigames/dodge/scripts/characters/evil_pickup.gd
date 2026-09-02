extends "res://minigames/dodge/scripts/characters/evil_train.gd"


# Stop spewing smoke when the truck crashes.
func unlock( switch: bool = true ):
	super.unlock( switch )
	if switch == false:
		$Particles2D.set_emitting(false)
