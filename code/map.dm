#define MAP_LEVELS_SPACE(_STATION)	levels = list(\
												/datum/map_level/station/_STATION, \
												/datum/map_level/debris_field, \
												/datum/map_level/asteroid_field\
												)

#define MAP_LEVELS_OCEAN(_STATION)	levels = list(\
												/datum/map_level/station/underwater/_STATION, \
												/datum/map_level/polaris, \
												/datum/map_level/trench\
												)


#define MAP_SPAWN_SHUTTLE 1
#define MAP_SPAWN_CRYO 2
#define MAP_SPAWN_MISSILE 3

#define MAP_NAME_RANDOM 1

var/global/map_setting = null
var/global/datum/map_settings/map_settings = null

//id corresponds to the name of the /obj/landmark/map
//playerPickable defines whether the map can be chosen by players when voting on a new map. Setting to ASS_JAM should allow it on the 13th only, and not on RP.
var/global/list/mapNames = list()
/*var/global/list/mapNames = list(
	"Clarion" = 		list("id" = "CLARION", 		"settings" = "destiny/clarion", "playerPickable" = 1),
	"Cogmap 1" = 		list("id" = "COGMAP", 		"settings" = "cogmap", 			"playerPickable" = 1),
	//"Construction" = list("id" = "CONSTRUCTION", "settings" = "construction"),
	"Cogmap 1 (Old)" = 	list("id" = "COGMAP_OLD", 	"settings" = "cogmap_old"),
	"Cogmap 2" = 		list("id" = "COGMAP2", 		"settings" = "cogmap2", 		"playerPickable" = 1, 	"MinPlayersAllowed" = 40),
	"Destiny" = 		list("id" = "DESTINY", 		"settings" = "destiny", 		"playerPickable" = 1),
	"Donut 2" = 		list("id" = "DONUT2", 		"settings" = "donut2",			"playerPickable" = ASS_JAM),
	"Horizon" = 		list("id" = "HORIZON", 		"settings" = "horizon", 		"playerPickable" = 1),
	"Linemap" = 		list("id" = "LINEMAP", 		"settings" = "linemap",			"playerPickable" = ASS_JAM),
	"Mushroom" =		list("id" = "MUSHROOM", 	"settings" = "mushroom",		"playerPickable" = ASS_JAM),
	"Trunkmap" = 		list("id" = "TRUNKMAP", 	"settings" = "trunkmap",		"playerPickable" = ASS_JAM),
	"Oshan Laboratory"= list("id" = "OSHAN", 		"settings" = "oshan", 			"playerPickable" = 1),
	"Samedi" = 			list("id" = "SAMEDI", 		"settings" = "samedi", 			"playerPickable" = ASS_JAM),
	"Atlas" = 			list("id" = "ATLAS", 		"settings" = "atlas", 			"playerPickable" = 1,	"MaxPlayersAllowed" = 30),
	"Manta" = 			list("id" = "MANTA", 		"settings" = "manta", 			"playerPickable" = 1),
)*/

/obj/landmark/map
	name = "map_setting"
	icon_state = "x3"
	invisibility = 101

/*	New()
		if (src.name != "map_setting")
			map_setting = src.name

			//find config in mapNames above
			for (var/map in mapNames)
				var/mapID = mapNames[map]["id"]

				if (mapID == map_setting)
					var/path = text2path("/datum/map_settings/" + mapNames[map]["settings"])
					map_settings = new path
					break

			//Fallback for an unfound map. Should never occur!!
			if (!map_settings)
				map_settings = new /datum/map_settings
				CRASH("A mapName entry for '[src.name]' wasn't found!")

		qdel(src)*/


/datum/map_settings
	var/name = "MAP"
	var/player_pickable = MAP_PICKABLE_ALWAYS
	var/list/levels = list()
	var/list/preloaded_levels = list(
										/datum/map_level/centcomm,
										/datum/map_level/spare
									)
	var/flags = 0
	var/min_players_allowed = 0
	var/max_players_allowed = 0
	var/display_name = MAP_NAME_RANDOM
	var/style = "station"
	var/default_gamemode = "secret"
	var/goonhub_map = "http://goonhub.com/maps/cogmap"
	var/arrivals_type = MAP_SPAWN_SHUTTLE
	var/dir_fore = null

	var/list/jobs_exclude = list(
								/datum/job/command/comm_officer,
								/datum/job/security/security_officer/manta,
								/datum/job/engineering/engineer/manta,
								/datum/job/special/random/radioshowhost/oshan,
								/datum/job/special/random/radioshowhost/manta,
								/datum/job/special/syndicate_specialist/oshan
								)

	var/list/supply_packs_blacklist = list(/datum/supply_packs/antisingularity)

	var/list/process_blacklist = list(/datum/controller/process/sea_hotspot_update)

	var/list/theft_objective_items = list(
											"Head of Security\'s beret" = /obj/item/clothing/head/helmet/HoS,
											"prisoner\'s beret" = /obj/item/clothing/head/beret/prisoner,
											"DetGadget hat" = /obj/item/clothing/head/det_hat/gadget,
											"authentication disk" = /obj/item/disk/data/floppy/read_only/authentication,
											"\'freeform\' AI module" = /obj/item/aiModule/freeform,
											"gene power module" = /obj/item/cloneModule/genepowermodule,
											"mainframe memory board" = /obj/item/disk/data/memcard/main2,
											"yellow cake" = /obj/item/reagent_containers/food/snacks/yellow_cake_uranium_cake,
											"aurora MKII utility belt" = /obj/item/storage/belt/utility/ceshielded,
											"much coveted Gooncode" = /obj/item/toy/gooncode
											)


	var/list/prefabs = list()
	var/titlecard_icon = 'icons/misc/widescreen.dmi'
	var/titlecard_icon_state = "title_main"
	var/titlecard_name = "Space Station 13"
	var/titlecard_desc = "The title card for it, at least."

	var/nuke_cinematic //Used only for Manta, presently.

	var/walls = /turf/simulated/wall
	var/rwalls = /turf/simulated/wall/r_wall
	var/auto_walls = 0

	var/windows = /obj/window
	var/windows_thin = /obj/window
	var/rwindows = /obj/window/reinforced
	var/rwindows_thin = /obj/window/reinforced
	var/windows_crystal = /obj/window/crystal
	var/windows_rcrystal = /obj/window/crystal/reinforced
	var/window_layer_full = null
	var/window_layer_north = null // cog2 panel windows need to go under stuff because ~perspective~
	var/window_layer_south = null
	var/auto_windows = 0

	var/ext_airlocks = /obj/machinery/door/airlock/external
	var/airlock_style = "gannets"
/*	var/list/airlocks = list(
									"com" = "/obj/machinery/door/airlock/glass/command",
									"eng" = "/obj/machinery/door/airlock/glass/engineering",
									"sec" = "/obj/machinery/door/airlock/glass",
									"med" = "/obj/machinery/door/airlock/glass/medical",
									"sci" = "/obj/machinery/door/airlock/glass",
									"maint" = "/obj/machinery/door/airlock/glass",
									"default" = "/obj/machinery/door/airlock"
									)
*/
	var/escape_centcom = /area/shuttle/escape/centcom
	var/escape_transit = /area/shuttle/escape/transit
	var/escape_station = /area/shuttle/escape/station
	var/escape_dir = SOUTH
	var/shuttle_map_turf = /turf/space

	var/merchant_left_centcom = /area/shuttle/merchant_shuttle/left_centcom
	var/merchant_left_station = /area/shuttle/merchant_shuttle/left_station
	var/merchant_right_centcom = /area/shuttle/merchant_shuttle/right_centcom
	var/merchant_right_station = /area/shuttle/merchant_shuttle/right_station

	var/list/valid_nuke_targets = list("the main security room" = list(/area/station/security/main),
		"the central research sector hub" = list(/area/station/science),
		"the cargo bay (QM)" = list(/area/station/quartermaster/office),
		"the engineering control room" = list(/area/station/engine/engineering, /area/station/engine/power),
		"the central warehouse" = list(/area/station/storage/warehouse),
		"the courtroom" = list(/area/station/crew_quarters/courtroom, /area/station/crew_quarters/juryroom),
		"the medbay" = list(/area/station/medical/medbay, /area/station/medical/medbay/surgery, /area/station/medical/medbay/lobby),
		"the station's cafeteria" = list(/area/station/crew_quarters/cafeteria),
		"the EVA storage" = list(/area/station/ai_monitored/storage/eva),
		"the robotics lab" = list(/area/station/medical/robotics))
//		"the public pool" = list(/area/station/crew_quarters/pool))

/datum/map_settings/New()
	if(flags & UNDERWATER_MAP)	map_currently_underwater = 1
	var/list/map_details = list()
	map_details["id"] = name
	map_details["settings"] = src
	map_details["playerPickable"] = player_pickable
	if(min_players_allowed)	map_details["MinPlayersAllowed"] = min_players_allowed
	if(max_players_allowed)	map_details["MaxPlayersAllowed"] = max_players_allowed
	mapNames[display_name] = map_details

	..()

/datum/map_settings/donut2
	name = "DONUT2"
	display_name = "Donut 2"
	player_pickable = MAP_PICKABLE_ASSDAY
	MAP_LEVELS_SPACE(donut2)
	goonhub_map = "http://goonhub.com/maps/donut2"
	escape_centcom = /area/shuttle/escape/centcom/donut2
	escape_transit = /area/shuttle/escape/transit/donut2
	escape_station = /area/shuttle/escape/station/donut2
	escape_dir = WEST // FUCK YOU DONUT2 I WAS NEARLY DONE AND THEN YOU THROW THIS AT ME AND NOW I HAVE TO ADD YOUR GODDAMN WEST-FACING SHUTTLE TO THE MAP ARGH *SCREAM *SCREAM *SCREAM

	merchant_left_centcom = /area/shuttle/merchant_shuttle/left_centcom/donut2
	merchant_left_station = /area/shuttle/merchant_shuttle/left_station/donut2
	merchant_right_centcom = /area/shuttle/merchant_shuttle/right_centcom/donut2
	merchant_right_station = /area/shuttle/merchant_shuttle/right_station/donut2

/datum/map_settings/cogmap_old
	name = "COGMAP_OLD"
	display_name = "Cogmap 1 (Old)"
	player_pickable = 0
	MAP_LEVELS_SPACE(cogmap_old)
	escape_centcom = /area/shuttle/escape/centcom/cogmap
	escape_transit = /area/shuttle/escape/transit/cogmap
	escape_station = /area/shuttle/escape/station/cogmap

	merchant_left_centcom = /area/shuttle/merchant_shuttle/left_centcom/cogmap
	merchant_left_station = /area/shuttle/merchant_shuttle/left_station/cogmap
	merchant_right_centcom = /area/shuttle/merchant_shuttle/right_centcom/cogmap
	merchant_right_station = /area/shuttle/merchant_shuttle/right_station/cogmap

/datum/map_settings/cogmap
	name = "COGMAP"
	display_name = "Cogmap 1"
	MAP_LEVELS_SPACE(cogmap)
	goonhub_map = "http://goonhub.com/maps/cogmap"
	walls = /turf/simulated/wall/auto/supernorn
	rwalls = /turf/simulated/wall/auto/reinforced/supernorn
	auto_walls = 1

	windows = /obj/window/auto
	windows_thin = /obj/window/pyro
	rwindows = /obj/window/auto/reinforced
	rwindows_thin = /obj/window/reinforced/pyro
	windows_crystal = /obj/window/auto/crystal
	windows_rcrystal = /obj/window/auto/crystal/reinforced
	window_layer_full = COG2_WINDOW_LAYER
	window_layer_north = GRILLE_LAYER+0.1
	window_layer_south = FLY_LAYER+1
	auto_windows = 1

	ext_airlocks = /obj/machinery/door/airlock/pyro/external
	airlock_style = "pyro"

	escape_centcom = /area/shuttle/escape/centcom/cogmap
	escape_transit = /area/shuttle/escape/transit/cogmap
	escape_station = /area/shuttle/escape/station/cogmap

	merchant_left_centcom = /area/shuttle/merchant_shuttle/left_centcom/cogmap
	merchant_left_station = /area/shuttle/merchant_shuttle/left_station/cogmap
	merchant_right_centcom = /area/shuttle/merchant_shuttle/right_centcom/cogmap
	merchant_right_station = /area/shuttle/merchant_shuttle/right_station/cogmap

/datum/map_settings/cogmap2
	name = "COGMAP2"
	display_name = "Cogmap 2"
	MAP_LEVELS_SPACE(cogmap2)
//	min_players_allowed = 40
	goonhub_map = "http://goonhub.com/maps/cogmap2"
	walls = /turf/simulated/wall/auto/supernorn
	rwalls = /turf/simulated/wall/auto/reinforced/supernorn
	auto_walls = 1

	windows = /obj/window/auto
	windows_thin = /obj/window/pyro
	rwindows = /obj/window/auto/reinforced
	rwindows_thin = /obj/window/reinforced/pyro
	windows_crystal = /obj/window/auto/crystal
	windows_rcrystal = /obj/window/auto/crystal/reinforced
	window_layer_full = COG2_WINDOW_LAYER
	window_layer_north = GRILLE_LAYER+0.1
	window_layer_south = FLY_LAYER+1
	auto_windows = 1

	ext_airlocks = /obj/machinery/door/airlock/pyro/external
	airlock_style = "pyro"

	escape_centcom = /area/shuttle/escape/centcom/cogmap2
	escape_transit = /area/shuttle/escape/transit/cogmap2
	escape_station = /area/shuttle/escape/station/cogmap2
	escape_dir = EAST

	merchant_left_centcom = /area/shuttle/merchant_shuttle/left_centcom/cogmap2
	merchant_left_station = /area/shuttle/merchant_shuttle/left_station/cogmap2
	merchant_right_centcom = /area/shuttle/merchant_shuttle/right_centcom/cogmap2
	merchant_right_station = /area/shuttle/merchant_shuttle/right_station/cogmap2

	valid_nuke_targets = list("the main security room" = list(/area/station/security/main),
		"the central research sector hub" = list(/area/station/science),
		"the cargo bay (QM)" = list(/area/station/quartermaster/office),
		"the thermo-electric generator room" = list(/area/station/engine/core),
		"the refinery (arc smelter)" = list(/area/station/quartermaster/refinery),
		"the medbay" = list(/area/station/medical/medbay, /area/station/medical/medbay/surgery),
		"the station's cafeteria" = list(/area/station/crew_quarters/cafeteria),
		"the net cafe" = list(/area/station/crew_quarters/info),
		"the artifact lab" = list(/area/station/science/artifact),
		"the genetics lab" = list(/area/station/medical/research))

/datum/map_settings/destiny
	name = "DESTINY"
	display_name = "NSS Destiny"
	MAP_LEVELS_SPACE(destiny)
	style = "ship"
	default_gamemode = "extended"
	goonhub_map = "http://goonhub.com/maps/destiny"
	arrivals_type = MAP_SPAWN_CRYO
	dir_fore = NORTH

	walls = /turf/simulated/wall/auto/gannets
	rwalls = /turf/simulated/wall/auto/reinforced/gannets
	auto_walls = 1

	escape_centcom = /area/shuttle/escape/centcom/destiny
	escape_transit = /area/shuttle/escape/transit/destiny
	escape_station = /area/shuttle/escape/station/destiny
	escape_dir = NORTH

	merchant_left_centcom = /area/shuttle/merchant_shuttle/left_centcom/destiny
	merchant_left_station = /area/shuttle/merchant_shuttle/left_station/destiny
	merchant_right_centcom = /area/shuttle/merchant_shuttle/right_centcom/destiny
	merchant_right_station = /area/shuttle/merchant_shuttle/right_station/destiny

	valid_nuke_targets = list("the main security room" = list(/area/station/security/main),
		"the central research sector hub" = list(/area/station/science),
		"the cargo bay (QM)" = list(/area/station/quartermaster/office),
		"the thermo-electric generator room" = list(/area/station/engine/core),
		"the refinery (arc smelter)" = list(/area/station/mining/refinery),
		"the courtroom" = list(/area/station/crew_quarters/courtroom),
		"the medbay" = list(/area/station/medical/medbay, /area/station/medical/medbay/lobby),
		"the bar" = list(/area/station/crew_quarters/bar),
		"the EVA storage" = list(/area/station/ai_monitored/storage/eva),
		"the artifact lab" = list(/area/station/science/artifact),
		"the robotics lab" = list(/area/station/medical/robotics))

/datum/map_settings/destiny/clarion
	name = "CLARION"
	display_name = "NSS Clarion"
	MAP_LEVELS_SPACE(clarion)
	goonhub_map = "http://goonhub.com/maps/clarion"

	valid_nuke_targets = list("the main security room" = list(/area/station/security/main),
		"the central research sector hub" = list(/area/station/science),
		"the cargo bay (QM)" = list(/area/station/quartermaster/office),
		"the thermo-electric generator room" = list(/area/station/engine/core),
		"the courtroom" = list(/area/station/crew_quarters/courtroom),
		"the medbay" = list(/area/station/medical/medbay, /area/station/medical/medbay/lobby),
		"the bar" = list(/area/station/crew_quarters/bar),
		"the EVA storage" = list(/area/station/ai_monitored/storage/eva),
		"the artifact lab" = list(/area/station/science/artifact),
		"the robotics lab" = list(/area/station/medical/robotics))

/datum/map_settings/horizon
	name = "HORIZON"
	display_name = "NSS Horizon"
	MAP_LEVELS_SPACE(horizon)
	style = "ship"
	goonhub_map = "http://goonhub.com/maps/horizon"
	walls = /turf/simulated/wall/auto/supernorn
	rwalls = /turf/simulated/wall/auto/reinforced/supernorn
	auto_walls = 1

	windows = /obj/window/auto
	windows_thin = /obj/window/pyro
	rwindows = /obj/window/auto/reinforced
	rwindows_thin = /obj/window/reinforced/pyro
	windows_crystal = /obj/window/auto/crystal
	windows_rcrystal = /obj/window/auto/crystal/reinforced
	window_layer_full = COG2_WINDOW_LAYER
	window_layer_north = GRILLE_LAYER+0.1
	window_layer_south = FLY_LAYER+1
	auto_windows = 1

	ext_airlocks = /obj/machinery/door/airlock/pyro/external
	airlock_style = "pyro"

	escape_centcom = /area/shuttle/escape/centcom/cogmap2
	escape_transit = /area/shuttle/escape/transit/cogmap2
	escape_station = /area/shuttle/escape/station/cogmap2
	escape_dir = EAST

	merchant_left_centcom = /area/shuttle/merchant_shuttle/left_centcom/cogmap
	merchant_left_station = /area/shuttle/merchant_shuttle/left_station/cogmap
	merchant_right_centcom = /area/shuttle/merchant_shuttle/right_centcom/cogmap
	merchant_right_station = /area/shuttle/merchant_shuttle/right_station/cogmap

	valid_nuke_targets = list("the courtroom" = list(/area/station/crew_quarters/courtroom),
		"the chapel" = list(/area/station/chapel/main),
		"the main security room" = list(/area/station/security/main),
		"the Quartermaster's Store (QM)" = list(/area/station/quartermaster),
		"the Engineering control room" = list(/area/station/engine/power),
		"that snazzy-lookin' sports bar up front" = list(/area/station/crew_quarters/fitness),
		"the main medical bay room" = list(/area/station/medical/medbay),
		"the research artifact lounge" = list(/area/station/science/artifact))

/datum/map_settings/manta
	name = "MANTA"
	display_name = "NSS Manta"
	MAP_LEVELS_OCEAN(manta)
	flags = UNDERWATER_MAP | MOVING_SUB_MAP | SUBMARINE_MAP

	jobs_exclude = list(
								/datum/job/security/security_officer,
								/datum/job/engineering/engineer,
								/datum/job/special/random/radioshowhost/oshan,
								/datum/job/special/random/radioshowhost,
								/datum/job/special/syndicate_specialist/oshan
								)
	supply_packs_blacklist = list()

	theft_objective_items = list(
											"Head of Security\'s beret" = /obj/item/clothing/head/helmet/HoS,
											"prisoner\'s beret" = /obj/item/clothing/head/beret/prisoner,
											"DetGadget hat" = /obj/item/clothing/head/det_hat/gadget,
											"authentication disk" = /obj/item/disk/data/floppy/read_only/authentication,
											"\'freeform\' AI module" = /obj/item/aiModule/freeform,
											"gene power module" = /obj/item/cloneModule/genepowermodule,
											"mainframe memory board" = /obj/item/disk/data/memcard/main2,
											"yellow cake" = /obj/item/reagent_containers/food/snacks/yellow_cake_uranium_cake,
											"aurora MKII utility belt" = /obj/item/storage/belt/utility/ceshielded,
											"much coveted Gooncode" = /obj/item/toy/gooncode,
											"Head of Security\'s war medal" = /obj/item/hosmedal,
											"Research Director\'s Diploma" = /obj/item/rddiploma,
											"Medical Director\'s Medical License" = /obj/item/mdlicense,
											"Head of Personnel\'s First Bill" = /obj/item/firstbill
											)

	prefabs = list("TRENCH" = list(/datum/generatorPrefab/sea_miner_manta))

	goonhub_map = "http://goonhub.com/maps/manta"
	titlecard_icon_state = "title_manta"
	titlecard_name = "The NSS Manta"
	titlecard_desc = "Some fancy comic about the NSS Manta and its travels on the planet Abzu."

	nuke_cinematic = "manta_nukies"

	walls = /turf/simulated/wall/auto/supernorn
	rwalls = /turf/simulated/wall/auto/reinforced/supernorn
	auto_walls = 1
	style = "ship"
	arrivals_type = MAP_SPAWN_CRYO

	windows = /obj/window/auto
	windows_thin = /obj/window/pyro
	rwindows = /obj/window/auto/reinforced
	rwindows_thin = /obj/window/reinforced/pyro
	windows_crystal = /obj/window/auto/crystal
	windows_rcrystal = /obj/window/auto/crystal/reinforced
	window_layer_full = COG2_WINDOW_LAYER
	window_layer_north = GRILLE_LAYER+0.1
	window_layer_south = FLY_LAYER+1
	auto_windows = 1

	ext_airlocks = /obj/machinery/door/airlock/pyro/external
	airlock_style = "pyro"
	shuttle_map_turf = /turf/space/fluid/manta

	escape_centcom = /area/shuttle/escape/centcom/manta
	escape_transit = /area/shuttle/escape/transit/manta
	escape_station = /area/shuttle/escape/station/manta
	escape_dir = NORTH

	merchant_left_centcom = /area/shuttle/merchant_shuttle/left_centcom/cogmap
	merchant_left_station = /area/shuttle/merchant_shuttle/left_station/cogmap/manta
	merchant_right_centcom = /area/shuttle/merchant_shuttle/right_centcom/cogmap
	merchant_right_station = /area/shuttle/merchant_shuttle/right_station/cogmap/manta

	valid_nuke_targets = list("the fitness room" = list(/area/station/crew_quarters/fitness),
		"the cargo bay" = list(/area/station/quartermaster/cargobay),
		"the bridge" = list(/area/station/bridge),
		"the medbay lobby" = list(/area/station/medical/medbay/lobby),
		"the engineering power room" = list(/area/station/engine/power),
		"the chapel" = list(/area/station/chapel/main),
		"the communications office" = list(/area/station/communications))

/datum/map_settings/mushroom
	name = "MUSHROOM"
	display_name = "Mushroom"
	player_pickable = MAP_PICKABLE_ASSDAY
	goonhub_map = "http://goonhub.com/maps/mushroom"
	MAP_LEVELS_SPACE(mushroom)
	escape_centcom = /area/shuttle/escape/centcom/cogmap2
	escape_transit = /area/shuttle/escape/transit/cogmap2
	escape_station = /area/shuttle/escape/station/cogmap2
	escape_dir = EAST

/datum/map_settings/trunkmap
	name = "TRUNKMAP"
	display_name = "Trunkmap"
	player_pickable = MAP_PICKABLE_ASSDAY
	MAP_LEVELS_SPACE(trunkmap)
	goonhub_map = "http://goonhub.com/maps/trunkmap"
	escape_centcom = /area/shuttle/escape/centcom/destiny
	escape_transit = /area/shuttle/escape/transit/destiny
	escape_station = /area/shuttle/escape/station/destiny
	escape_dir = NORTH

	merchant_left_centcom = /area/shuttle/merchant_shuttle/left_centcom/destiny
	merchant_left_station = /area/shuttle/merchant_shuttle/left_station/destiny
	merchant_right_centcom = /area/shuttle/merchant_shuttle/right_centcom/destiny
	merchant_right_station = /area/shuttle/merchant_shuttle/right_station/destiny

/datum/map_settings/linemap
	name = "LINEMAP"
	display_name = "Linemap"
	player_pickable = MAP_PICKABLE_ASSDAY
	arrivals_type = MAP_SPAWN_CRYO
	MAP_LEVELS_SPACE(linemap)
	goonhub_map = "http://goonhub.com/maps/linemap"

	walls = /turf/simulated/wall/auto/gannets
	rwalls = /turf/simulated/wall/auto/reinforced/gannets
	auto_walls = 1

	escape_centcom = /area/shuttle/escape/centcom/donut2
	escape_transit = /area/shuttle/escape/transit/donut2
	escape_station = /area/shuttle/escape/station/donut2
	escape_dir = WEST

	merchant_left_centcom = /area/shuttle/merchant_shuttle/left_centcom/destiny
	merchant_left_station = /area/shuttle/merchant_shuttle/left_station/destiny
	merchant_right_centcom = /area/shuttle/merchant_shuttle/right_centcom/destiny
	merchant_right_station = /area/shuttle/merchant_shuttle/right_station/destiny

/datum/map_settings/atlas
	name = "ATLAS"
	display_name = "NCS Atlas"
	MAP_LEVELS_SPACE(atlas)
	max_players_allowed = 30
	style = "ship"
	goonhub_map = "http://goonhub.com/maps/atlas"
	arrivals_type = MAP_SPAWN_CRYO
	dir_fore = NORTH

	walls = /turf/simulated/wall/auto/supernorn
	rwalls = /turf/simulated/wall/auto/reinforced/supernorn
	auto_walls = 1
	airlock_style = "pyro"

	escape_centcom = /area/shuttle/escape/centcom/cogmap2
	escape_transit = /area/shuttle/escape/transit/cogmap2
	escape_station = /area/shuttle/escape/station/cogmap2
	escape_dir = EAST

	merchant_left_centcom = /area/shuttle/merchant_shuttle/left_centcom/cogmap
	merchant_left_station = /area/shuttle/merchant_shuttle/left_station/cogmap
	merchant_right_centcom = /area/shuttle/merchant_shuttle/right_centcom/cogmap
	merchant_right_station = /area/shuttle/merchant_shuttle/right_station/cogmap

	valid_nuke_targets = list("the main security room" = list(/area/station/security/main),
		"the cargo bay (QM)" = list(/area/station/quartermaster/),
		"the bridge" = list(/area/station/bridge/),
		"the thermo-electric generator room" = list(/area/station/engine/core),
		"the medbay" = list(/area/station/medical/medbay, /area/station/medical/medbay/surgery),
		"the station's cafeteria" = list(/area/station/crew_quarters/cafeteria),
		"the telescience lab" = list(/area/station/science/teleporter),
		"the genetics lab" = list(/area/station/medical/research, /area/station/medical/medbay/cloner))

/datum/map_settings/samedi
	name = "SAMEDI"
	display_name = "Samedi"
	player_pickable = MAP_PICKABLE_ASSDAY
	goonhub_map = "http://goonhub.com/maps/samedi"
	MAP_LEVELS_SPACE(samedi)
	walls = /turf/simulated/wall/auto/supernorn
	rwalls = /turf/simulated/wall/auto/reinforced/supernorn
	auto_walls = 1

	windows = /obj/window/auto
	windows_thin = /obj/window/pyro
	rwindows = /obj/window/auto/reinforced
	rwindows_thin = /obj/window/reinforced/pyro
	windows_crystal = /obj/window/auto/crystal
	windows_rcrystal = /obj/window/auto/crystal/reinforced
	window_layer_full = COG2_WINDOW_LAYER
	window_layer_north = GRILLE_LAYER+0.1
	window_layer_south = FLY_LAYER+1
	auto_windows = 1

	ext_airlocks = /obj/machinery/door/airlock/pyro/external
	airlock_style = "pyro"

	escape_centcom = /area/shuttle/escape/centcom/cogmap2
	escape_transit = /area/shuttle/escape/transit/cogmap2
	escape_station = /area/shuttle/escape/station/cogmap2
	escape_dir = EAST

	merchant_left_centcom = /area/shuttle/merchant_shuttle/left_centcom/cogmap
	merchant_left_station = /area/shuttle/merchant_shuttle/left_station/cogmap
	merchant_right_centcom = /area/shuttle/merchant_shuttle/right_centcom/cogmap
	merchant_right_station = /area/shuttle/merchant_shuttle/right_station/cogmap

/datum/map_settings/oshan
	name = "OSHAN"
	display_name = "Oshan Laboratory"
	MAP_LEVELS_OCEAN(oshan)
	flags = UNDERWATER_MAP
	goonhub_map = "http://goonhub.com/maps/oshan"

	arrivals_type = MAP_SPAWN_MISSILE

	jobs_exclude = list(
								/datum/job/command/comm_officer,
								/datum/job/security/security_officer/manta,
								/datum/job/engineering/engineer/manta,
								/datum/job/special/random/radioshowhost/,
								/datum/job/special/random/radioshowhost/manta
								)

	process_blacklist = list()

	titlecard_icon_state = "title_oshan"
	titlecard_name = "Oshan Laboratory"
	titlecard_desc = "An underwater laboratory on the planet Abzu."

	prefabs = list("TRENCH" = list(/datum/generatorPrefab/elevator, /datum/generatorPrefab/sea_miner_oshan))

	walls = /turf/simulated/wall/auto/supernorn
	rwalls = /turf/simulated/wall/auto/reinforced/supernorn
	auto_walls = 1

	windows = /obj/window/auto
	windows_thin = /obj/window/pyro
	rwindows = /obj/window/auto/reinforced
	rwindows_thin = /obj/window/reinforced/pyro
	windows_crystal = /obj/window/auto/crystal
	windows_rcrystal = /obj/window/auto/crystal/reinforced
	window_layer_full = COG2_WINDOW_LAYER
	window_layer_north = GRILLE_LAYER+0.1
	window_layer_south = FLY_LAYER+1
	auto_windows = 1

	ext_airlocks = /obj/machinery/door/airlock/pyro/external
	airlock_style = "pyro"

	escape_centcom = /area/shuttle/escape/centcom/sealab
	escape_transit = /area/shuttle/escape/transit/sealab
	escape_station = /area/shuttle/escape/station/sealab
	shuttle_map_turf = /turf/space/fluid

	merchant_left_centcom = /area/shuttle/merchant_shuttle/left_centcom/cogmap
	merchant_left_station = /area/shuttle/merchant_shuttle/left_station/cogmap
	merchant_right_centcom = /area/shuttle/merchant_shuttle/right_centcom/cogmap
	merchant_right_station = /area/shuttle/merchant_shuttle/right_station/cogmap

	valid_nuke_targets = list("the fitness room" = list(/area/station/crew_quarters/fitness),
		"the quartermaster's office" = list(/area/station/quartermaster/office),
		"the refinery (arc smelter)" = list(/area/station/quartermaster/refinery),
		"the courtroom" = list(/area/station/crew_quarters/courtroom),
		"the medbay" = list(/area/station/medical/medbay),
		"the bar" = list(/area/station/crew_quarters/bar),
		"the chapel" = list(/area/station/chapel/main))
		//"the radio lab" = list(/area/station/crew_quarters/radio))

/area/shuttle/escape/centcom
	icon_state = "shuttle_escape"
	donut2
		icon_state = "shuttle_escape-dnt2"
	cogmap
		icon_state = "shuttle_escape-cog1"
	cogmap2
		icon_state = "shuttle_escape-cog2"
	destiny
		icon_state = "shuttle_escape-dest"
	sealab
		icon_state = "shuttle_escape-sealab"
	manta
		icon_state = "shuttle_escape-manta"
		filler_turf = "/turf/space/fluid/manta"

/area/shuttle/escape/station
	icon_state = "shuttle_escape"
	donut2
		icon_state = "shuttle_escape-dnt2"
	cogmap
		icon_state = "shuttle_escape-cog1"
	cogmap2
		icon_state = "shuttle_escape-cog2"
	destiny
		icon_state = "shuttle_escape-dest"
	sealab
		icon_state = "shuttle_escape-sealab"
	manta
		icon_state = "shuttle_escape-manta"

/area/shuttle/escape/station/New()
	if(map_settings.flags & UNDERWATER_MAP)
		ambient_light = OCEAN_LIGHT
	..()

/area/shuttle/escape/transit
	icon_state = "shuttle_escape"
	donut2
		icon_state = "shuttle_escape-dnt2"
		warp_dir = WEST
	cogmap
		icon_state = "shuttle_escape-cog1"
	cogmap2
		icon_state = "shuttle_escape-cog2"
		warp_dir = EAST
	destiny
		icon_state = "shuttle_escape-dest"
	sealab
		icon_state = "shuttle_escape-sealab"
		warp_dir = EAST
	battle_shuttle
		icon_state = "shuttle_escape-battle-shuttle"
		warp_dir = EAST
	manta
		icon_state = "shuttle_escape-manta"
		warp_dir = NORTH

/area/shuttle/merchant_shuttle/left_centcom
	icon_state = "shuttle_merch_l"
	donut2
		icon_state = "shuttle_merch_l-dnt2"
	cogmap
		icon_state = "shuttle_merch_l-cog1"
	cogmap2
		icon_state = "shuttle_merch_l-cog2"
	destiny
		icon_state = "shuttle_merch_l-dest"
	sealab
		icon_state = "shuttle_merch_l-sealab"
/area/shuttle/merchant_shuttle/left_station
	icon_state = "shuttle_merch_l"
	donut2
		icon_state = "shuttle_merch_l-dnt2"
	cogmap
		icon_state = "shuttle_merch_l-cog1"
	cogmap2
		icon_state = "shuttle_merch_l-cog2"
	destiny
		icon_state = "shuttle_merch_l-dest"
	sealab
		icon_state = "shuttle_merch_l-sealab"

/area/shuttle/merchant_shuttle/left_station/New()
	if(map_settings.flags & UNDERWATER_MAP)
		ambient_light = OCEAN_LIGHT
	..()


/area/shuttle/merchant_shuttle/right_centcom
	icon_state = "shuttle_merch_r"
	donut2
		icon_state = "shuttle_merch_r-dnt2"
	cogmap
		icon_state = "shuttle_merch_r-cog1"
	cogmap2
		icon_state = "shuttle_merch_r-cog2"
	destiny
		icon_state = "shuttle_merch_r-dest"
	sealab
		icon_state = "shuttle_merch_r-sealab"
/area/shuttle/merchant_shuttle/right_station
	icon_state = "shuttle_merch_r"
	donut2
		icon_state = "shuttle_merch_r-dnt2"
	cogmap
		icon_state = "shuttle_merch_r-cog1"
	cogmap2
		icon_state = "shuttle_merch_r-cog2"
	destiny
		icon_state = "shuttle_merch_r-dest"
	sealab
		icon_state = "shuttle_merch_r-sealab"

/area/shuttle/merchant_shuttle/right_station/New()
	if(map_settings.flags & UNDERWATER_MAP)
		ambient_light = OCEAN_LIGHT
	..()

/proc/dir2nautical(var/req_dir, var/fore_dir = NORTH, var/side = 0)
	if (!isnum(req_dir) || !isnum(fore_dir))
		return "unknown[side ? " side" : null]"
	if (req_dir == fore_dir)
		return "north"
	else if (turn(fore_dir, 90) == req_dir)
		return "west[side ? " side" : null]"
	else if (turn(fore_dir, -90) == req_dir)
		return "east[side ? " side" : null]"
	else if (turn(fore_dir, 180) == req_dir)
		return "south"
	else // we're on some kind of diagonal idk
		if (turn(fore_dir, 45) == req_dir)
			return "north-west"
		else if (turn(fore_dir, -45) == req_dir)
			return "north-east"
		else if (turn(fore_dir, 135) == req_dir)
			return "south-west"
		else if (turn(fore_dir, -135) == req_dir)
			return "south-east"
	return "unknown[side ? " side" : null]"

/proc/getMapNameFromID(id)
	for (var/map in mapNames)
		if (id == mapNames[map]["id"])
			return map

	return 0
