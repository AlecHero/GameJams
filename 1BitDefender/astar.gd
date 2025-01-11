extends Node

const TILEMAP_SIZE = Vector2i(41,25)
const TILE_SIZE = Vector2i(16,16)
const MAP_RECT = Rect2i(Vector2i.ZERO, TILEMAP_SIZE)
enum ASTAR_TYPES {REGULAR, CLIMB, FLYING}

func create_astar(tilemap : TileMapLayer, astar_type : ASTAR_TYPES) -> Dictionary:
	var astar = AStarGrid2D.new()
	astar.region = MAP_RECT
	astar.cell_size = TILE_SIZE
	astar.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_AT_LEAST_ONE_WALKABLE
	astar.update()
	
	var gates = [[],[],[],[]]
	var spawns = []
	
	for i in TILEMAP_SIZE.x:
		for j in TILEMAP_SIZE.y:
			var coords = Vector2i(i,j)
			var tile_data = tilemap.get_cell_tile_data(coords)
			if not tile_data:
				print("missing tile at: ", coords)
				continue
			var tile_type = tile_data.get_custom_data("type")
			
			match tile_type:
				"block":
					astar.set_point_solid(coords)
				"wall":
					if astar_type == ASTAR_TYPES.FLYING:
						astar.set_point_weight_scale(coords, 10)
					elif astar_type == ASTAR_TYPES.REGULAR:
						astar.set_point_solid(coords)
				"gate1": gates[0].append(coords)
				"gate2": gates[1].append(coords)
				"gate3": gates[2].append(coords)
				"gate4": gates[3].append(coords)
				"low_wall":
					if astar_type == ASTAR_TYPES.CLIMB:
						astar.set_point_weight_scale(coords, 20)
					elif astar_type == ASTAR_TYPES.FLYING:
						astar.set_point_weight_scale(coords, 1)
					elif astar_type == ASTAR_TYPES.REGULAR:
						astar.set_point_solid(coords)
				"spawn":
					if astar_type == ASTAR_TYPES.REGULAR:
						spawns.append(coords)
				_:
					astar.set_point_weight_scale(coords, 1)
	var astar_dict = {"astar":astar, "gates":gates, "spawns":spawns,}
	return astar_dict

func get_type_path(level_mng, pos1 : Vector2i, pos2 : Vector2i, astar_type : ASTAR_TYPES, gates_active : Array[int]):
	var tilemap = level_mng.current_layer
	var astar_dict = level_mng.all_astar[astar_type]
	var astar = astar_dict["astar"]
	var gates = astar_dict["gates"]
	
	for i in range(4):
		if gates[i].size() > 0:
			astar.set_point_solid(gates[i][gates_active[i]], true)
	
	var path = astar.get_id_path(
		tilemap.local_to_map(pos1),
		tilemap.local_to_map(pos2),
		true)
	
	for i in range(4):
		if gates[i].size() > 0:
			astar.set_point_solid(gates[i][gates_active[i]], false)
	
	return path.slice(1)
