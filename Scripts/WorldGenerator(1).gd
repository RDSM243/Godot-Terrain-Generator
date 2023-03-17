extends Node2D

const WIDTH = 33
const HEIGHT = 28

var mainLayer : OpenSimplexNoise
var temperatureLayer: OpenSimplexNoise
var enviromentLayer : OpenSimplexNoise

var pos: = Vector2.ZERO
var rec: = Rect2()

var pos_chunk = Vector2.ZERO
var old_chunk = Vector2.ZERO

var changed_tiles = []

var generated_enviroment_objects = []

var enviromentObjects = {
	'tree': load("res://Nodes/Enviroment/tree.tscn"),
	'snow_tree': load("res://Nodes/Enviroment/snow_tree.tscn")
}

func _ready():
	GameManager.world = self
	mainLayer = create_noise_layer(150)#valor normal period = 400
	temperatureLayer = create_noise_layer(450)
	enviromentLayer = create_noise_layer(1)
	
	rec = Rect2((WIDTH/2*-1),(HEIGHT/2*-1),WIDTH,HEIGHT)
	create_noise()
	pass

func _process(delta : float) -> void:
	pos_chunk = $Chunk.world_to_map(GameManager.playerNode.global_position)
	test_chunk(pos_chunk)
	pass

func create_noise() -> void:
	for i in $Enviroment.get_children():
		#verificando se o enviroment não está dentro do chunk pra assim remove-lo 
		if !GameManager.is_between_positions(i.global_position,$Tiles.map_to_world(rec.position),$Tiles.map_to_world(rec.position+rec.size)):
			i.die()
	$Tiles.clear()
	for x in rec.size.x:
		for y in rec.size.y:
			$Tiles.set_cell(x + rec.position.x, y + rec.position.y, generate_index(Vector2(x + rec.position.x,y + rec.position.y), mainLayer.get_noise_2d(float(x+rec.position.x), float(y+rec.position.y)),temperatureLayer.get_noise_2d(float(x+rec.position.x), float(y+rec.position.y)),enviromentLayer.get_noise_2d(float(x+rec.position.x), float(y+rec.position.y))))
#			update_ground_bitmask(Vector2(x+rec.position.x,y+rec.position.y))
	#atualizando informações geradas com informações salvadas
	for t in changed_tiles:
		if $Tiles.get_cellv(t[1]) != t[0] && GameManager.is_between_positions(t[1], rec.position,rec.position+rec.size):
			$Tiles.set_cellv(t[1], t[0])
			
	update_chunk()
	pass

func generate_index(tilePos, mainLayer, temperatureLayer, enviromentLayer) -> int:
	if mainLayer < 0.1:
		if temperatureLayer < -0.19:
			if enviromentLayer < -0.50:
				generate_enviroment('snow_tree',$Tiles.map_to_world(tilePos)+Vector2(16,-8))
			return GameManager.TILES.snow
		elif temperatureLayer < 0.13:
			if enviromentLayer < -0.45:
				generate_enviroment('tree',$Tiles.map_to_world(tilePos)+Vector2(16,-8))
			return GameManager.TILES.grass
		else:
			return GameManager.TILES.desert_sand
	else:
		return GameManager.TILES.water
	pass
	
func test_chunk(pos_chunk) -> void:
	if old_chunk != pos_chunk:
		old_chunk = pos_chunk
		pos = $Tiles.world_to_map(GameManager.playerNode.global_position)
		rec = Rect2(pos.x - (WIDTH/2),pos.y - (HEIGHT/2),WIDTH,HEIGHT)
		create_noise()
	pass

func update_chunk():
	$Tiles.update_bitmask_region(rec.position,rec.position+rec.size)
	pass

func create_noise_layer(layerPeriod=64, layerOctaves=3, layerLacunarity=2,  layerSeed=GameManager.worldSeed):
	var noiseLayer = OpenSimplexNoise.new()
	noiseLayer.seed = layerSeed
	noiseLayer.period = layerPeriod
	noiseLayer.octaves = layerOctaves
	noiseLayer.lacunarity = layerLacunarity
	
	return noiseLayer
	pass

func insert_tile(id, pos):
	changed_tiles.append([id, pos])
	pass

func generate_enviroment(enviroment_id, pos:Vector2):
	#verificando se o objeto ja foi gerado
	if !generated_enviroment_objects.has(pos):
		var tempObject = enviromentObjects[enviroment_id].instance()
		generated_enviroment_objects.append(pos)
		tempObject.position = pos
		$Enviroment.call_deferred("add_child", tempObject)
	pass

func update_ground_bitmask(tilePos):
	var cell_id = $Tiles.get_cellv(tilePos)
	
	if cell_id == -1: return
	
	#capturando todas as dimensões do tile
	var tl = $Tiles.get_cell(tilePos.x - 1, tilePos.y - 1) != -1
	var t = $Tiles.get_cell(tilePos.x, tilePos.y - 1) != -1
	var tr = $Tiles.get_cell(tilePos.x + 1, tilePos.y - 1) != -1
	var l = $Tiles.get_cell(tilePos.x - 1, tilePos.y) != -1
	var r = $Tiles.get_cell(tilePos.x + 1, tilePos.y) != -1
	var bl = $Tiles.get_cell(tilePos.x - 1, tilePos.y + 1) != -1
	var b = $Tiles.get_cell(tilePos.x, tilePos.y + 1) != -1
	var br = $Tiles.get_cell(tilePos.x + 1, tilePos.y + 1) != -1
	
	var bitmask = 0
	
	bitmask += TileSet.BIND_CENTER
	if tl && t && l:
		bitmask += TileSet.BIND_TOPLEFT
	if tr && t && r:
		bitmask += TileSet.BIND_TOPRIGHT
	if bl && b && l:
		bitmask += TileSet.BIND_BOTTOMLEFT
	if br && b && r:
		bitmask += TileSet.BIND_BOTTOMRIGHT
	if t:
		bitmask += TileSet.BIND_TOP
	if l:
		bitmask += TileSet.BIND_LEFT
	if r:
		bitmask += TileSet.BIND_RIGHT
	if b:
		bitmask += TileSet.BIND_BOTTOM
		
	for x in range(16):
			for y in range(12):
				if $Tiles.tile_set.autotile_get_bitmask(cell_id, Vector2(x, y)) == bitmask:
					$Tiles.set_cell(tilePos.x, tilePos.y, cell_id, false, false, false, Vector2(x, y))
	pass
