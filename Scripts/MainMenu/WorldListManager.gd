extends VBoxContainer

#"pressed", self, "_on_LoadBtn_pressed"

onready var worldContainer = load("res://Nodes/MainMenu/WorldContainer.tscn")

var worldFiles = []

func _ready():
	#capturando arquivos na pasta de mundos
	worldFiles = GameManager.get_files_in_directory("user://TerrainGenerationEngine2/Worlds")
	
	#gerando lista com os mundos da pasta "Worlds"
	for world in worldFiles:
		var dir = Directory.new()
		if dir.file_exists(str("user://TerrainGenerationEngine2/Worlds/",world)):
			var dataFile = File.new()
			dataFile.open(str("user://TerrainGenerationEngine2/Worlds/",world), File.READ)
			var worldData = dataFile.get_var()
			var tempWorldContainer = worldContainer.instance()
			tempWorldContainer.get_node("WorldNameTxt").text = worldData["WorldName"]
			tempWorldContainer.worldSeed = worldData["WorldSeed"]
			add_child(tempWorldContainer)
	pass

func loadWorld(worldSeed, worldName):
	GameManager.worldSeed = worldSeed
	GameManager.worldName =  worldName
	
	get_tree().change_scene("res://Scenes/Game.tscn")
	pass
