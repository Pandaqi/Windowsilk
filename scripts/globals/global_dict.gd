extends Node

var cfg = {
	'player_starting_points': 5
}

var silk_types = {
	"regular": { "frame": 0, "color": Color(1,1,1) },
	"speedy": { "frame": 1, "color": Color(0,1,0) }
}

# All parameters are FALSE by default (this means simplified code and consistency)
# Non-boolean parameters, if omitted are just set to the basic value

# frame => the frame in the spritesheet
# points => points rewarded for eating
# move => type (def=web), speed, flee, chase, forbid_backtrack
# trail => what trail (silk type) it leaves; null means no trail
var entities = {
	"player_spider": {
		"frame": 0,
		"points": 5,
		"trail": null,
		"move": {
			"speed": 170.0
		}
	},
	
	"tiny_spider": { 
		"frame": 1, 
		"points": 1,
		"trail": "speedy",
		"move": {
			"flee": true, 
			"speed": 40.0,
		} 
	},
	
	"fly": {
		"frame": 2,
		"points": 2,
		"trail": "speedy",
		"move": {
			"type": "fly",
			"chase": true, 
			"speed": 70.0
		}
	}
	
	
}
