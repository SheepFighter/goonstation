var/global/list/map_level_flags = list()
var/global/list/map_level_names = list()

/datum/map_level
	var/name = ""
	var/flags = 0
	var/file = null
	var/list/prefab_tags
	var/NUMPREFABS = 0	//How many prefabs to place. It'll try it's hardest to place this many at the very least. You're basically guaranteed this amount of prefabs.
	var/NUMPREFABSEXTRA = 0	//Up to how many extra prefabs to place randomly. You might or might not get these extra ones.
	var/datum/mapGenerator/MapGen
	var/z
	var/turf/basic_turf

/datum/map_level/dummy
	name = "Dummy Level"
	flags = LEVEL_RESTRICTED

/datum/map_level/centcomm
	name = "Centcomm"
	flags = LEVEL_RESTRICTED | LEVEL_ADMIN


/datum/map_level/spare
	name = "Spare Level"
	flags = LEVEL_RESTRICTED | SPARE_LEVEL

/datum/map_level/debris_field
	name = "Debris Field"
	file = 'maps/z3.dmm'

/datum/map_level/polaris
	name = "NSS Polaris"
	file = 'maps/z3_blank.dmm'
	flags = LEVEL_RESTRICTED | GHOST_RESTRICTED

/datum/map_level/asteroid_field
	name = "Asteroid Field"
	file = 'maps/z5.dmm'
	MapGen = /datum/mapGenerator/asteroidsDistance
	prefab_tags = list("ASTEROID")
	NUMPREFABS = 5
	NUMPREFABSEXTRA = 3
	flags = MINING_LEVEL
/datum/map_level/trench
	name = "Trench"
	file ='maps/z5_trench.dmm'
	MapGen = /datum/mapGenerator/seaCaverns
	prefab_tags = list("TRENCH")
	NUMPREFABS = 18
	NUMPREFABSEXTRA = 6
	flags = GHOST_RESTRICTED | MINING_LEVEL
	basic_turf = /turf/space/fluid/trench
/datum/map_level/station
	flags = STATION_LEVEL

/datum/map_level/station/cogmap
	name = "Cogmap"
	file = 'maps/cogmap.dmm'

/datum/map_level/station/cogmap2
	name = "Cogmap2"
	file = 'maps/cogmap2.dmm'

/datum/map_level/station/atlas
	name = "NSS Atlas"
	file = 'maps/atlas.dmm'

/datum/map_level/station/destiny
	name = "NSS Destiny"
	file = 'maps/destiny.dmm'

/datum/map_level/station/clarion
	name = "NSS Clarion"
	file = 'maps/clarion.dmm'

/datum/map_level/station/horizon
	name = "NSS Horizon"
	file = 'maps/horizon.dmm'

/datum/map_level/station/kondaru
	name = "Kondaru"
	file = 'maps/kondaru.dmm'

/datum/map_level/station/underwater/oshan
	name = "Oshan Laboratory"
	file = 'maps/oshan.dmm'


/datum/map_level/station/underwater/manta
	name = "NSS Manta"
	file = 'maps/manta.dmm'

/datum/map_level/station/cogmap_old
	name = "Cogmap"
	file = 'maps/unused/cogmap.dmm'

/datum/map_level/station/donut2
	name = "Donut 2"
	file = 'maps/unused/donut2_new_walls.dmm'

/datum/map_level/station/mushroom
	name = "Mushroom Station"
	file = 'maps/unused/mushroom_new_walls.dmm'

/datum/map_level/station/linemap
	name = "Linemap"
	file = 'maps/unused/linemap.dmm'

/datum/map_level/station/trunkmap
	name = "Trunkmap"
	file = 'maps/unused/trunkmap.dmm'

/datum/map_level/station/samedi
	name = "SS Samedi"
	file = 'maps/unused/samedi.dmm'

/datum/map_level/station/fleet
	name = "Bellerophon Fleet"
	file = 'maps/fleet.dmm'

/datum/map_level/station/density
	name = "Density"
	file = 'maps/density.dmm'


/datum/map_level/New(var/index)
	..()
	z = index
	map_level_flags += flags
	map_level_names += name

	if(MapGen)	MapGen = new MapGen
	if(file)
		var/turf/current_default
		if(basic_turf)
			current_default = default_world_turf
			default_world_turf = basic_turf
		var/dmm_suite/D = new/dmm_suite()
		D.read_map(file2text(file))
		if(current_default)
			default_world_turf = current_default
	else
		return

	if(flags & STATION_LEVEL)
		hotspot_controller.create_hotspots(z)
	if(prefab_tags)
		PlacePrefabs()
	if(MapGen)
		MapGeneration()
		if(map_currently_underwater)
			hotspot_controller.generate_map(z)



/datum/map_level/proc/PlacePrefabs()
	var/list/prefabs = list()
	for(var/tag in prefab_tags)
		if(miningModifiers[tag])	prefabs += miningModifiers[tag]
	var/extra = rand(0,NUMPREFABSEXTRA)
	for(var/n=0, n<NUMPREFABS+extra, n++)
		var/datum/generatorPrefab/M = pickPrefab(prefabs)
		if(M)
			var/maxX = (world.maxx - M.prefabSizeX - AST_MAPBORDER)
			var/maxY = (world.maxy - M.prefabSizeY - AST_MAPBORDER)
			var/stop = 0
			var/count= 0
			var/maxTries = (M.required ? 200:33)
			while(!stop && count < maxTries) //Kinda brute forcing it. Dumb but whatever.
				var/turf/target = locate(rand(1+AST_MAPBORDER, maxX), rand(1+AST_MAPBORDER,maxY), z)
				var/ret = M.applyTo(target)
				if(ret == 0)
					logTheThing("debug", null, null, "Prefab placement #[n] [M.type] failed due to blocked area. [target] @ [showCoords(target.x, target.y, target.z)]")
				else
					logTheThing("debug", null, null, "Prefab placement #[n] [M.type][M.required?" (REQUIRED)":""] succeeded. [target] @ [showCoords(target.x, target.y, target.z)]")
					stop = 1
				count++
				if(count >= 33)
					logTheThing("debug", null, null, "Prefab placement #[n] [M.type] failed due to maximum tries [maxTries][M.required?" WARNING: REQUIRED FAILED":""]. [target] @ [showCoords(target.x, target.y, target.z)]")
		else break
/datum/map_level/proc/MapGeneration()
	if(MapGen)
		MapGen.generate(z)