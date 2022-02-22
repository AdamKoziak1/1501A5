extends Items

func _ready():
	$AnimatedSprite.animation = "Not exploding"

func _process(delta):
	if(shortCircuit == 1):
		$AnimatedSprite.animation = "Exploding"
	else: 
		$AnimatedSprite.animation = "Not exploding"

