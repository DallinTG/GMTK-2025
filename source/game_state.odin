package game

import "core:fmt"
import "core:math"
import "core:math/rand"
import b2 "box2d"
import rl "vendor:raylib"
import "base:runtime"



state::struct{
	particle:all_particle_data,
	player:player,
	physics_object:[400]physics_object,
	astroids_count:i32,
	max_astroids:i32,
	score:i32,
	temp_score_cros:bool,
	thruster_sound_cd:f32,
	star_count:i32,
	planit_img:Animation_Name,
	player_alive_last_frame:bool,
	was_lost_in_space:bool,
	overide_left_click:bool,
	rand_number:f32,
}

player::struct{
	ph_data:physics_object,
}

physics_object::struct{
	is_alive:bool,
	mas:f32,
	size:f32,
	pos:[2]f32,
	rot:f32,
	rot_speed:f32,
	velocity:[2]f32,
	img:Texture_Name,
}