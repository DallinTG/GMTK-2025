package game

import "core:fmt"
import "core:math/linalg"
import "core:math"
import "core:math/rand"
import "base:runtime"
import rl "vendor:raylib"
import noise"core:math/noise"
import clay "/clay-odin"
import "core:log"

mesh:rl.Mesh
modle:rl.Model
mat:rl.Material

init::proc(){
	rl.InitAudioDevice()
	init_clay_ui()
	init_sounds()
	init_shaders()
	init_atlases()
	init_box_2d()
	init_global_animations()
	init_defalts()

	g.cam.position = {0,0,-50}
	g.cam.target = {0,0,0}
	g.cam.fovy = 720
	g.cam.projection=.ORTHOGRAPHIC
	g.cam.up = {0,-1,0}

	// mesh=rl.GenMeshCube(100,100,1)
	// mesh:rl.Mesh=rl.GenMeshPlane(1,1,1,1)

	// mesh:=gen_mesh_quad(.Topple_Red)
	// mesh:=gen_mesh_tmap_bace({64,64},.B_Block)
	t_map:=[][]Texture_Name{
		{.B_Block,.B_Block,.B_Block,.B_Block,.B_Block,.B_Block,.B_Block,.B_Block,.B_Block,.B_Block},
		{.B_Block,.B_Block,.B_Block,.B_Block,.B_Block,.B_Block,.B_Block,.B_Block,.B_Block,.B_Block},
		{.B_Block,.B_Block,.B_Block,.B_Block,.B_Block,.B_Block,.B_Block,.B_Block,.B_Block,.B_Block},
		{.B_Block,.B_Block,.B_Block,.B_Block,.B_Block,.B_Block,.B_Block,.B_Block,.B_Block,.B_Block},
		{.B_Block,.B_Block,.B_Block,.B_Block,.B_Block,.B_Block,.B_Block,.B_Block,.B_Block,.B_Block},
		{.B_Block,.B_Block,.B_Block,.B_Block,.B_Block,.B_Block,.B_Block,.B_Block,.B_Block,.B_Block},
		{.B_Block,.B_Block,.B_Block,.B_Block,.B_Block,.B_Block,.B_Block,.Big_Lazer9,.B_Block,.B_Block},
		{.B_Block,.B_Block,.B_Block,.B_Block,.B_Block,.B_Block,.B_Block,.B_Block,.B_Block,.B_Block},
		{.B_Block,.B_Block,.B_Block,.B_Block,.B_Block,.B_Block,.B_Block,.B_Block,.B_Block,.B_Block},
		{.B_Block,.B_Block,.B_Block,.B_Block,.B_Block,.B_Block,.B_Block,.B_Block,.B_Block,.B_Block},

	}


	mesh:=gen_mesh_tmap(t_map[:][:])

	
	// rl.UploadMesh(&mesh,true)
	modle=rl.LoadModelFromMesh(mesh)
	mat= rl.LoadMaterialDefault()
	mat.maps[rl.MaterialMapIndex.ALBEDO].texture=g.atlas
	mat.maps[rl.MaterialMapIndex.ALBEDO].color = {255,2,2,255}

	modle.materials[0]=mat
	
	// rand.reset(rand.uint64()+cast(u64)(rl.GetTime()*100000000000))
}

update :: proc() {
	maintain_window_info()
	maintain_timers()
	do_inputs()
	update_global_animations()
	calc_particles()
	sim_box_2d()
	manage_sound_bytes()
	update_clay_ui()


}

draw :: proc() {
	

	rl.BeginDrawing()
	rl.ClearBackground({214, 192, 237,255})
	rl.BeginMode3D(g.cam)//g.cam
	rl.BeginShaderMode(g.as.shaders.bace)

	draw_particles()
	// rl.DrawCube({0,100,100},10,10,10,{255,5,5,255})
	// draw_image(.B_Block,{100,100,100,100},0.281,tint={55,255,255,255})
	// draw_image(.B_Block,{50,50,100,100},1,tint={55,55,55,255})
	// draw_image(.B_Block,{100,50,100,100},-.10,tint={255,255,55,255})
	// rl.DrawText("waffles",100,0,10,{0,0,0,255})
	// rl.DrawBillboardPro(g.cam, g.as.atlas, atlas_textures[.Background_Cloudes].rect, {10,10,0},{0,-1,0},{720,200}, {0,0}, 0, {255,255,255,255})

	rl.DrawModel(modle,{0,0,0},16,{255,255,255,255})

	rl.EndShaderMode()
	
	
	rl.EndMode3D()

	rl.BeginMode2D(ui_camera())
	clayRaylibRender(&ui_render_command)
	rl.EndMode2D()
	rl.DrawFPS(10,10)
	rl.EndDrawing()
}

ui_camera :: proc() -> rl.Camera2D {
	return {
		// zoom = f32(rl.GetScreenHeight())/PIXEL_WINDOW_HEIGHT,
		zoom = 1
	}
}
