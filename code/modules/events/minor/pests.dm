/datum/random_event/minor/pests
	name = "Pests"

	event_effect()
		..()
		var/list/EV = list()
		for(var/obj/landmark/S in landmarks)//world)
			if (S.name == "peststart")
				EV.Add(S.loc)

			LAGCHECK(LAG_LOW)
		if(!EV.len)
			return
		var/pestlandmark = pick(EV)
		var/masterspawnamount = rand(4,12)
		var/spawnamount = masterspawnamount
		var/type = rand(1,12)
		switch (type)
			if (1)
				while (spawnamount > 0)
					new /obj/critter/roach(pestlandmark)
					spawnamount -= 1
					LAGCHECK(LAG_LOW)
			if (2)
				while (spawnamount > 0)
					new /obj/critter/mouse(pestlandmark)
					spawnamount -= 1
					LAGCHECK(LAG_LOW)
			if (5)
				while (spawnamount > 0)
					new /obj/critter/spacebee(pestlandmark)
					spawnamount -= 1
					LAGCHECK(LAG_LOW)
		//pestlandmark.visible_message("A group of [type] emerges from their hidey-hole")


/datum/random_event/minor/electricmalfunction
	name = "Electrical Malfunction"

	New()
		if(map_settings.flags & MOVING_SUB_MAP)
			..()
		else
			del src
	event_effect()
		..()
		var/obj/machinery/junctionbox/J = mantaJunctionbox[rand(1,mantaJunctionbox.len)]
		if (J.broken == 1)
			return
		J.Breakdown()

