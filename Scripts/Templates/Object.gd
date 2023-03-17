extends StaticBody2D

export(int) var life = 3

func checklife():
	if life <= 0:
		call_deferred("queue_free")
	pass
