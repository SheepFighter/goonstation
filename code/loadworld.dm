
/proc/get_valid_maps(var/ass_jam = FALSE)
	var/list/valid_maps = list()
	for(var/MAP in mapNames)
		var/list/L = mapNames[MAP]
		if(L["playerPickable"])	valid_maps += L["settings"]
	return valid_maps

/proc/fetch_map(var/ass_jam = FALSE)
	var/next_map_name = world.load_intra_round_value("next_map")
	var/datum/map_settings/next_map
	if(next_map_name)	next_map = mapNames[next_map_name]["settings"]

	if(!next_map)
		next_map = pick(get_valid_maps())
	return next_map

/proc/preload_world()
	var/list/MapLevels = map_settings.preloaded_levels
	for(var/m = 1 to MapLevels.len)
		var/datum/map_level/map_level = MapLevels[m]
		MapLevels[m] = new map_level(m)

/proc/load_world()

	var/OverallTime = world.timeofday
	var/list/MapLevels = map_settings.preloaded_levels
	if(world.maxz && MapLevels.len < world.maxz)
		var/b = world.maxz - MapLevels.len
		for(var/a = b to world.maxz)
			MapLevels[a] = new /datum/map_level/dummy(a)
		world.log << "Generated [b] dummy level[b > 1 ? "s" : ""]"
	MapLevels = map_settings.levels
	var/initial_z = world.maxz ? world.maxz : 0
	for(var/m = 1 to MapLevels.len)
		var/datum/map_level/map_level = MapLevels[m]
		var/Time = world.timeofday
		map_level = new map_level(m + initial_z)
		MapLevels[m] = map_level
		world.log << "Loaded [map_level.name] in [((world.timeofday - Time)/10)] seconds!"
	for(var/m in MapLevels)
		if(!m)
			MapLevels -= m

	if((map_settings.preloaded_levels.len + MapLevels.len) < world.maxz)
		world.log << "WARNING: Number of z-levels exceeds number of map-level datums. This build is borked!"
		for(var/a in MapLevels)
			world.log << a
	world.log << "Loaded World in [((world.timeofday - OverallTime)/10)] seconds!"


/proc/post_load_world()
	for(var/atom/ATOM in initiation_queue)	ATOM.Initiate()

	for(var/area/A in world)
		if(A.contents.len)
			var/areaname = A.name
			if(!areas_by_name[areaname])
				if(area_names.len)
					for(var/n = 1 to area_names.len)
						if(sorttext(areaname, area_names[n]) > -1)
							area_names.Insert(n, areaname)
							break
						else if(n == area_names.len)
							area_names += areaname
				else
					area_names += areaname
			areas_by_name[areaname] = A
			areas_in_map += A
