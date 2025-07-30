package game

import "core:fmt"
import "core:math"
import "core:math/rand"
import b2 "box2d"
import rl "vendor:raylib"
import "base:runtime"



state::struct{
	particle:all_particle_data,
}
