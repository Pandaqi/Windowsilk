extends Node

var cfg = {
	'player_starting_points': 2,
	'max_points_capacity': 9,
	
	'allow_eating_same_species': false,
	'objective_points_per_player': 20,
	'objective_uses_home_base': true,
	
	'respawn_on_death': true,
	'point_reset_val': 0, # used on respawn AND draining points at storage
	
	'allow_quick_paint': false, # "quick_paint" = hopping on an edge, then immediately hopping off to paint it, boring and cheaty strategy
	
	'debug_terrain_types': true,
	'line_thickness': 30,
	'draw_outlines_on_web': true,
	'outline_darkening': 0.5,
	'outline_width': 3,
	
	'point_difference_eating_players': 0,
	'point_difference_holds_for_all': true,
	
	'players_leave_trail': true,
	'short_owner_fade_time': 20.0,
	'long_owner_fade_time': 300.0,
	'owned_silk_catches_any_bug': true,
	
	'allow_eating_small_players': false,
	'bigger_entities_move_slower': true,
	'paint_trails_when_jumping': true,
	
	"ai_can_enter_owned_silk": true,
	
	"max_entities_per_type": 10,
	
	# Narrow bugs tend to be hard to see, so scale them up a bit
	# A similar thing happens on certain silk icons
	"narrow_bug_upscale": 1.3,
	"narrow_icon_upscale": 2.0,
	
	"min_edges_on_home_base": 3,
	
	# TO DO: If I ever set this to true, I should change collision layer/mask on entities to hit each other
	'entities_obstruct_each_other': false,
	
}

var player_data = [
	{ 'team': 0, 'color': Color(1.0, 15/255.0, 9/255.0) },
	{ 'team': 1, 'color': Color(31/255.0, 1.0, 30/255.0) },
	{ 'team': 2, 'color': Color(41/255.0, 39/255.0, 1.0) },
	{ 'team': 3, 'color': Color(1.0, 9/255.0, 230/255.0) },
	{ 'team': 4, 'color': Color(1.0, 213/255.0, 9/255.0) },
	{ 'team': 5, 'color': Color(9/255.0, 1.0, 235/255.0) },
]

var silk_categories = {
	"neutral": { "color": Color(1,1,1) },
	"movement": { "color": Color(23/255.0, 169/255.0, 15/255.0) },
	"web": { "color": Color(15/255.0, 156/255.0, 169/255.0) },
	"jumping": { "color": Color(15/255.0, 51/255.0, 169/255.0) },
	"collecting": { "color": Color(120/255.0, 15/255.0, 169/255.0) },
	"aggression": { "color": Color(169/255.0, 15/255.0, 45/255.0) },
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
	
	"aggressor": { "frame": 6, "category": "web", "narrow": true },
	"strong": { "frame": 7, "category": "web", "narrow": true },
	"fragile": { "frame": 8, "category": "web", "narrow": true },
	"timebomb": { "frame": 9, "category": "web", "narrow": true },
	"featherlight": { "frame": 10, "category": "web", "narrow": true },
	"oneway": { "frame": 11, "category": "web" },
	
	"worthless": { "frame": 12, "category": "collecting" },
	"doubler": { "frame": 13, "category": "collecting" },
	"shield": { "frame": 14, "category": "collecting" },
	"time_gainer": { "frame": 15, "category": "collecting" },
	"time_loser": { "frame": 16, "category": "collecting" },
	"gobbler": { "frame": 17, "category": "collecting" },
	
	"noisemaker": { "frame": 18, "category": "misc" },
	"attractor": { "frame": 19, "category": "misc" },
	"lowlife": { "frame": 20, "category": "misc" },
	
	"flight": { "frame": 21, "category": "jumping" },
	"poison": { "frame": 22, "category": "aggression" }
	
}

# All parameters are FALSE by default (this means simplified code and consistency)
# Non-boolean parameters, if omitted, are just set to the basic value

# frame => the frame in the spritesheet
# points => points rewarded for eating
# move => type (def=web), static, speed, flee, chase, forbid_backtrack
# trail => what trail (silk type) it leaves --- leave out for no trail
# collect => cannibal (eats same species), always (can always be eaten)
# legs => type (eight, six, four, or custom), color --- leave out for no legs
# antenna => offset (where it starts), dir (how it points), dist (how much it's allowed to stray from default point)

var entities = {
	"player_spider": {
		"frame": 0,
		"points": 5,
		"move": {
			"speed": 120.0
		},
		"collect": {
			"cannibal": true
		},
		"legs": {
			"type": "eight",
			"color": "player_color"
		},
		"wings": {
			"type": "player_spider",
			"hide_when_landed": true,
			"use_dynamic_color": true,
			"max_rot": 0.45*PI
		}
	},
	
	"larva": {
		"frame": 1,
		"points": 1,
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
		"trail": "featherlight",
		"specialty": "featherlight",
		"move": {
			"speed": 40.0,
			"flee": true,
		},
		"legs": {
			"type": "eight",
			"color": Color(0,40/255.0,43/255.0) # TO DO
		}
	},
	
	"flea": {
		"frame": 3,
		"points": 2,
		"trail": "speedy",
		"specialty": "speedy",
		"move": {
			"flee": true,
			"stamina": 1500.0
		},
		"legs": {
			"type": "six",
			"color": Color(61/255.0,34/255.0,0)
		},
		"antenna": {
			"type": "flea",
			"color": Color(1.0, 0.0, 0.0)
		}
	},
	
	"silverfish": {
		"frame": 4,
		"points": 3,
		"trail": "slippery",
		"specialty": "slippery",
		"move": {
			"speed": 120.0,
			"always": true,
			"flee": true,
		},
		"legs": {
			"type": "six",
			"color": Color(41/255.0, 41/255.0, 41/255.0),
			"scale_offset": 0.25,
			"scale_thickness": 0.5
		},
		"antenna": {
			"type": "silverfish",
			"color": Color(0.9, 0.9, 0.9)
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
			"jump": true,
			"jump_dist": 600.0,
		},
		"legs": {
			"type": "four",
			"color": Color(129/255.0, 21/255.0, 26/255.0)
		},
		"antenna": {
			"type": "grasshopper",
			"color": Color(193/255.0, 37/255.0, 44/255.0),
			"scale_thickness": 2.0
		}
	},
	
	"locust": {
		"frame": 6,
		"points": 0,
		"trail": "doubler",
		"specialty": "doubler",
		"visuals": {
			"narrow": true
		},
		"move": {
			"shuffle": true,
			"jump": true,
			"jump_dist": 600.0,
		},
		"legs": {
			"type": "six",
			"color": Color(0, 42/255.0, 7/255.0),
			"scale_offset": 0.25
		},
		"antenna": {
			"type": "locust",
			"color": Color(96/255.0, 114/255.0, 61/255.0),
		}
	},
	
	# NOTE: the "noisemaker" specialty overrides the jump button to make noise instead, that's why we enable the "fake_jump" module here
	"cricket": {
		"frame": 7,
		"points": 5, 
		"trail": "noisemaker",
		"specialty": "noisemaker",
		"move": {
			"fake_jump": true 
		},
		"collect": {
			"friendly": true
		},
		"legs": {
			"type": "four",
			"color": Color(30/255.0, 34/255.0, 148/255.0)
		},
		"antenna": {
			"type": "cricket",
			"color": Color(41/255.0, 46/255.0, 214/255.0)
		}
	},
	
	"cockroach": {
		"frame": 8,
		"points": 4,
		"move": {
			"flee": true,
			"chase": true,
			"chase_type": "cockroach",
			"speed": 110.0,
		},
		"collect": {
			"cannibal": true
		},
		"legs": {
			"type": "six",
			"color": Color(136/255.0, 9/255.0, 41/255.0)
		},
		"antenna": {
			"type": "cockroach",
			"color": Color(193/255.0, 37/255.0, 77/255.0),
		}
	},
	
	"beetle": {
		"frame": 9,
		"points": 6,
		"trail": "shield",
		"specialty": "shield",
		"move": {
			"speed": 50.0,
			"chase": true,
		},
		"legs": {
			"type": "six",
			"color": Color(71/255.0, 24/255.0, 99/255.0)
		},
		"collect": {
			"ignore_specialty": true
		}
	},
	
	"flightless_fruit_fly": {
		"frame": 10,
		"points": 1,
		"trail": "regular",
		"specialty": "regular",
		"move": {
			"flee": true,
			"speed": 80.0
		},
		"legs": {
			"type": "six",
			"color": Color(109/255.0, 48/255.0, 11/255.0)
		},
		"antenna": {
			"type": "fruit_fly",
			"color": Color(0, 45/255.0, 1/255.0)
		}
	},
	
	"regular_fruit_fly": {
		"frame": 11,
		"points": 1,
		"trail": "regular",
		"specialty": "regular",
		"move": {
			"type": "fly",
			"land": true,
			"flee": true,
			#"shuffle": true,
			"speed": 80.0
		},
		"antenna": {
			"type": "fruit_fly",
			"color": Color(1.0, 242/255.0, 199/255.0)
		},
		"wings": {
			"type": "regular_fruit_fly",
			"min_rot": 0.1*PI,
			"max_rot": 0.3*PI
		}
	},
	
	"aphid": {
		"frame": 12,
		"points": 2,
		"trail": "fragile",
		"specialty": "fragile",
		"move": {
			"flee": true,
			"speed": 70.0
		},
		"collect": {
			"friendly": true
		},
		"legs": {
			"type": "six",
			"color": Color(169/255.0, 195/255.0, 33/255.0)
		},
		"antenna": {
			"type": "aphid",
			"color": Color(169/255.0, 195/255.0, 33/255.0)
		}
	},
	
	"mealybug": {
		"frame": 13,
		"points": 2,
		"trail": "sticky",
		"specialty": "sticky",
		"collect": {
			"friendly": true
		},
		"move": {
			"speed": 50.0,
			"flee": true,
		},
		"antenna": {
			"type": "mealybug",
			"color": Color(1.0, 249/255.0, 233/255.0)
		}
	},
	
	"ant": {
		"frame": 14,
		"points": 5,
		"trail": "strong",
		"move": {
			"speed": 90.0,
			"chase": true,
		},
		"legs": {
			"type": "six",
			"color": Color(122/255.0, 51/255.0, 19/255.0)
		},
		"antenna": {
			"type": "ant",
			"color": Color(122/255.0, 51/255.0, 19/255.0)
		}
	},
	
	# NOTE: Giving something low stamina, but high speed
	# Makes it a "sprinter" that moves in short bursts
	"mealworm": {
		"frame": 15,
		"points": 7,
		"trail": "timebomb",
		"visuals": {
			"narrow": true
		},
		"move": {
			"stamina": 500,
			"speed": 120.0,
			"chase": true,
			"worm": true
		},
		"antenna": {
			"type": "mealworm",
			"color": Color(1.0, 166/255.0, 41/255.0)
		}
	},
	
	"small_caterpillar": {
		"frame": 16,
		"points": 3,
		"trail": "gobbler",
		"specialty": "gobbler",
		"visuals": {
			"narrow": true
		},
		"move": {
			"worm": true,
			"chase": true,
		},
		"collect": {
			"cannibal": true
		},
		"antenna": {
			"type": "caterpillar",
			"color": Color(134/255.0, 165/255.0, 2/255.0)
		}
	},
	
	"earwig": {
		"frame": 17,
		"points": 2,
		"trail": "aggressor",
		"specialty": "aggressor",
		"move": {
			"chase": true,
		},
		"collect": {
			"cannibal": true
		},
		"legs": {
			"type": "six",
			"color": Color(53/255.0, 33/255.0, 43/255.0)
		},
		"antenna": {
			"type": "earwig",
			"color": Color(53/255.0, 33/255.0, 43/255.0)
		}
	},
	
	"fly": {
		"frame": 18,
		"points": 1,
		"trail": "flight",
		"specialty": "flight",
		"move": {
			"type": "fly",
			"land": true,
			"flee": true,
		},
		"wings": {
			"type": "fly",
			"show_in_front": true,
			"speed": 1.25,
		}
	},
	
	"wasp": {
		"frame": 19,
		"points": 0,
		"trail": "worthless",
		"specialty": "worthless",
		"move": {
			"type": "fly",
			"shuffle": true
		},
		"wings": {
			"type": "wasp",
			"show_in_front": true,
			"speed": 1.5,
		},
		"antenna": {
			"type": "wasp",
			"color": Color(31/255.0, 23/255.0, 0)
		}
	},
	
	"gnat": {
		"frame": 20,
		"points": 2,
		"trail": "slowy",
		"specialty": "slowy",
		"move": {
			"type": "fly",
			"land": true,
			"chase": true
		},
		"wings": {
			"type": "gnat",
			"show_in_front": true,
			"speed": 1.5,
		},
		"antenna": {
			"type": "gnat",
			"color": Color(22/255.0, 24/255.0, 85/255.0),
			"scale_thickness": 0.5
		}
	},
	
	"butterfly": {
		"frame": 21,
		"points": 5,
		"trail": "attractor",
		"specialty": "attractor",
		"move": {
			"type": "fly",
			"land": true,
			"flee": true,
			"fake_jump": true
		},
		"wings": {
			"type": "butterfly",
			"min_rot": 0,
			"max_rot": 0,
			"collapse_using_scale": true
		},
		"antenna": {
			"type": "butterfly",
			"color": Color(170/255.0, 37/255.0, 22/255.0),
		}
	},
	
	"bee": {
		"frame": 22,
		"points": 5,
		"trail": "time_gainer",
		"specialty": "time_gainer",
		"move": {
			"type": "fly",
			"land": true,
			"flee": true,
			"smooth": true # TO DO: IMPLEMENT?
		},
		"wings": {
			"type": "bee",
			"speed": 1.25,
		},
		"antenna": {
			"type": "bee",
			"color": Color(94/255.0, 63/255.0, 32/255.0)
		}
	},
	
	"moth": {
		"frame": 23,
		"points": 2,
		"trail": "oneway",
		"specialty": "oneway",
		"move": {
			"type": "fly",
			"land": true,
			"chase": true,
		},
		"wings": {
			"type": "moth",
			"min_rot": -0.1*PI,
			"max_rot": 0.05*PI,
			"show_in_front": true
		},
		"antenna": {
			"type": "moth",
			"color": Color(236/255.0, 72/255.0, 114/255.0)
		}
	},
	
	"hornet": {
		"frame": 24,
		"points": 9,
		"trail": "poison",
		"specialty": "poison",
		"move": {
			"type": "fly",
			"chase": true
		},
		"wings": {
			"type": "hornet",
			"min_rot": 0,
			"max_rot": 0.2*PI,
			"speed": 1.75,
			"show_in_front": true
		},
		"antenna": {
			"type": "hornet",
			"color": Color(90/255.0, 31/255.0, 13/255.0)
		}
	},
	
	"mosquito": {
		"frame": 25,
		"points": 3,
		"trail": "time_loser",
		"specialty": "time_loser",
		"move": {
			"type": "fly",
			"chase": true,
			"land": true
		},
		"wings": {
			"type": "mosquito",
			"min_rot": 0.05*PI,
			"max_rot": 0.25*PI,
			"speed": 2.0,
			"show_in_front": true
		},
		"antenna": {
			"type": "mosquito",
			"color": Color(66/255.0, 30/255.0, 89/255.0),
			"scale_thickness": 0.5
		}
	}
	
}
