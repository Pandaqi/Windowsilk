extends Node2D

var particle_scenes ={
	"blast": preload("res://scenes/particles/blast_particles.tscn"),
	"point": preload("res://scenes/particles/point_particles.tscn"),
	"eat": preload("res://scenes/particles/eat_particles.tscn"),
	"stuck": preload("res://scenes/particles/stuck_particles.tscn"),
	"good": preload("res://scenes/particles/good_particles.tscn"),
	"bad": preload("res://scenes/particles/bad_particles.tscn")
}

func create_particles(pos, type):
	var p = particle_scenes[type].instance()
	p.set_position(pos)
	add_child(p)

func create_blast_particles(pos):
	create_particles(pos, "blast")

func create_point_particles(pos):
	create_particles(pos, "point")

func create_eat_particles(pos):
	create_particles(pos, "eat")

func create_stuck_particles(pos):
	create_particles(pos, "stuck")

func create_good_particles(pos):
	create_particles(pos, "good")

func create_bad_particles(pos):
	create_particles(pos, "bad")
