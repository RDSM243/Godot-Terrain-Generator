extends Node

var playerNode = null
var UI = null
var isConsoleVisible = false
var world = null
var worldSeed = 0
var worldName = ""
var tileWidthSp = 32
var tileHeightSp = 32

var command_history = []

const TILES = {
	"grass": 0,
	"water" : 1,
	"desert_sand" : 2,
	"snow": 3
}

func regenerate_world():
	generateSeed()
	get_tree().reload_current_scene()
	pass

func generateSeed():
	randomize()
	worldSeed = randi()
	pass

func loadInfos():
	var dir = Directory.new()
	dir.open("user://TerrainGenerationEngine2/Worlds")
	if dir.file_exists("data_file.dat"):
		var dataFile = File.new()
		dataFile.open("user://data_file.dat", File.READ)
		#capturar os dados aqui
		dataFile.close()
	pass

func saveInfos():
	var dataFile = File.new()
	#salvar os dados na variavel data
	var data = {}
	dataFile.open("user://TerrainGenerationEngine2/Worlds/data_file.dat", File.WRITE)
	dataFile.store_var(data)
	dataFile.close()
	pass

func get_files_in_directory(path):
	var files = []
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if !dir.current_is_dir():
				files.append(file_name)
			file_name = dir.get_next()
	return files
	pass
	
func is_between_positions(inside_pos:Vector2, pos1:Vector2, pos2:Vector2):
	if (inside_pos.x > pos1.x && inside_pos.x < pos2.x) && (inside_pos.y > pos1.y && inside_pos.y < pos2.y):
		return true
	else:
		return false 
	pass
