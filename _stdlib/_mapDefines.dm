//Map Flags
#define UNDERWATER_MAP	1
#define MOVING_SUB_MAP	2
#define SUBMARINE_MAP	4

//Level Flags
#define LEVEL_RESTRICTED	1
#define GHOST_RESTRICTED	2
#define	STATION_LEVEL		4
#define MINING_LEVEL		8
#define	ADMIN_LEVEL			16
#define	SPARE_LEVEL			32

//PlayerPickable
#define MAP_PICKABLE_ALWAYS	1
#ifdef ASS_JAM
#define MAP_PICKABLE_ASSDAY	1
#else
#define MAP_PICKABLE_ASSDAY	0
#endif
