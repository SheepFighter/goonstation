datum/controller/process/sea_hotspot_update
	var/tmp/datum/hotspot_controller/controller

	setup()
		name = "Sea Hotspot Process"
		schedule_interval = 600 // important : this controls the speed of drift for every hotspot!
		controller = global.hotspot_controller

	doWork()
		if (controller)
			if (map_currently_underwater)
				controller.process()
			else
				controller = 0
				global.hotspot_controller.clear()

