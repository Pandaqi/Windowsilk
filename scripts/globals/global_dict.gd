extends Node

var cfg = {
	'player_starting_points': 5,
	'allow_eating_same_species': false,
	
	'debug_terrain_types': true,
	'line_thickness': 20,
	
	# TO DO: If I ever set this to true, I should change collision layer/mask on entities to hit each other
	'entities_obstruct_each_other': false
}

var silk_categories = {
	"neutral": { "color": Color(1,1,1) },
	"movement": { "color": Color(23/255.0, 169/255.0, 15/255.0) },
	"web": { "color": Color(15/255.0, 156/255.0, 169/255.0) },
	"jumping": { "color": Color(15/255.0, 51/255.0, 169/255.0) },
	"collecting": { "color": Color(120/255.0, 15/255.0, 169/255.0) },
	"??": { "color": Color(169/255.0, 15/255.0, 45/255.0) },
	"misc": { "color": Color(169/255.0, 107/255.0, 15/255.0) }
}

var silk_types = {
	"regular": { "frame": 0, "category": "neutral" },
	"speedy": { "frame": 1, "category": "movement" },
	"slowy": { "frame": 2, "category": "movement" },
	"slippery": { "frame": 3, "category": "movement" },
	
	"trampoline": { "frame": 4, "category": "jumping" },
	"sticky": { "frame": 5, "category": "jumping" },
	
	# TO DO: jumping will probably get some weird powerups, like being able to CURVE your jump or something => but that's unsure for now, so just continue with other stuff
	
	"aggressor": { "frame": 6, "category": "web" },
	"strong": { "frame": 7, "category": "web" },
	"fragile": { "frame": 8, "category": "web" },
	"timebomb": { "frame": 9, "category": "web" },
	"featherlight": { "frame": 10, "category": "web" },
	"oneway": { "frame": 11, "category": "web" },
	
	"worthless": { "frame": 12, "category": "collecting" },
	"doubler": { "frame": 13, "category": "collecting" },
	
	"noisemaker": { "frame": 13, "category": "misc" }
}

# All parameters are FALSE by default (this means simplified code and consistency)
# Non-boolean parameters, if omitted, are just set to the basic value

# frame => the frame in the spritesheet
# points => points rewarded for eating
# move => type (def=web), static, speed, flee, chase, forbid_backtrack
# trail => what trail (silk type) it leaves; null means no trail
var entities = {
	"player_spider": {
		"frame": 0,
		"points": 5,
		"trail": null,
		"move": {
			"speed": 170.0
		},
		"collect": {
			"cannibal": true
		}
	},
	
	"larva": {
		"frame": 1,
		"points": 1,
		"trail": null,
		"move": {
			"static": true
		},
		"collect": {
			"always": true
		}
	},
	
	"tiny_spider": { 
		"frame": 2, 
		"points": 1,
		"trail": null,
		"move": {
			"speed": 40.0,
		}
	},
	
	"flea": {
		"frame": 3,
		"points": 2,
		"trail": "speedy",
		"move": {
			"flee": true,
			"speed": 140.0,
			"stamina": 300.0
		}
	},
	
	"silverfish": {
		"frame": 4,
		"points": 3,
		"trail": "slippery",
		"move": {
			"speed": 200.0,
			"always": true
		}
	},
	
	# NOTE: combining "jump" and "static" automatically makes a creature that ONLY jumps, never walks/moves normally
	
	"grasshopper": {
		"frame": 5,
		"points": 4,
		"trail": "trampoline",
		"specialty": "trampoline",
		"move": {
			"static": true,
			"jump": true
		}
	},
	
	"locust": {
		"frame": 6,
		"points": 1,
		"trail": "doubler",
		"specialty": "doubler",
		"move": {
			"shuffle": true,
			"jump": true
		}
	},
	
	"cricket": {
		"frame": 7,
		"points": 5, 
		"trail": "noisemaker",
		"specialty": "noisemaker"
	},
	
	"cockroach": {
		"frame": 8,
		"points": 4,
		"move": {
			"flee": true,
			"chase": true,
			"chase_type": "cockroach",
			"speed": 150.0,
		},
		"collect": {
			"cannibal": true
		}
	},
	
	"beetle": {
		"frame": 9,
		"points": 6,
		"trail": "shield",
		"specialty": "shield",
		"move": {
			"speed": 50.0
		}
	},
	
	"flightless_fruit_fly": {
		"frame": 10,
		"points": 1,
		"trail": "regular",
		"specialty": "erase",
		"move": {
			"flee": true,
			"speed": 80.0
		}
	},
	
	"regular_fruit_fly": {
		"frame": 11,
		"points": 1,
		"trail": "regular",
		"specialty": "erase",
		"move": {
			"fly": true,
			"flee": true,
			"shuffle": true,
			"speed": 80.0
		}
	}
	
}
