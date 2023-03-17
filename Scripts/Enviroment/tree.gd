extends "res://Scripts/Templates/Object.gd"

func _on_treeHitBox_area_entered(area):
	if area.name == "playerHitBox":
		die()
	pass # Replace with function body.

func die():
	GameManager.world.generated_enviroment_objects.remove(GameManager.world.generated_enviroment_objects.find(global_position))
	life = 0
	checklife()
	pass
