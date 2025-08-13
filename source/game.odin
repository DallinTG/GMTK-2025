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
	// rl.SetTargetFPS(59)
	g.cam.position = {0,0,-50}
	g.cam.target = {0,0,0}
	g.cam.fovy = 1009*4
	g.cam.projection=.ORTHOGRAPHIC
	g.cam.up = {0,-1,0}





	
	// rl.UploadMesh(&mesh,true)
	modle=rl.LoadModelFromMesh(mesh)
	mat= rl.LoadMaterialDefault()
	mat.maps[rl.MaterialMapIndex.ALBEDO].texture=g.atlas
	mat.maps[rl.MaterialMapIndex.ALBEDO].color = {255,2,2,255}

	modle.materials[0]=mat
	restart_game()

	
	// rand.reset(rand.uint64()+cast(u64)(rl.GetTime()*100000000000))
}
planit_chance:[]Animation_Name:{.Green_Planit,.Green_Planit,.Dry_Planit,.Moon_Planit,.White_Stare,.Yelow_Stare,.Ice_Planit,.Gass_2_Planit,.Lava_Planit}
// planit_chance:[]Animation_Name:{.Lava_Planit}
restart_game::proc(){
	if g.h_score<g.st.score{
		 g.h_score=g.st.score
	}
	g.st={}
	g.st.rand_number= rand.float32_range(0,1)
	g.st.planit_img = rand.choice(planit_chance)
	g.player.ph_data.pos={0,300+planit_size}
	g.player.ph_data.velocity={50+planit_size/10,0}
	g.player.ph_data.is_alive =true
	g.st.player_alive_last_frame =true
	g.player.ph_data.size=16
	g.st.max_astroids = 5
	g.st.score = -1

	g.as.cur_music=rand.choice(g.as.music[:])
	rl.PlayMusicStream(g.as.cur_music)      
	rl.SetMusicVolume(g.as.cur_music , .10)  
	
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
	update_song()
	game_update_tick()
}
game_update_tick::proc(){



	maintanin_score()
	mainrain_stars()
	check_if_player_is_in_bounds()
	if g.time.is_60h_this_frame {
		// planit_rot+=.05
		maintanin_astroid_numbers()
		tick_physics_object(&g.player.ph_data)
		tick_player_player()
		for &obj in &g.physics_object{
			tick_physics_object(&obj)
		}
	}
	if g.player_alive_last_frame&&g.player.ph_data.is_alive==false{
		g.player_alive_last_frame=false
		play_sound(.explosion,.25)
		g.player.ph_data.is_alive=false
		for i in 0..<100+cast(i32)g.player.ph_data.size+rand.int31_max(100) {
			temp_life:=rand.float32_range(.4,.6)
			temp_wh:[2]f32={rand.float32_range(2,8),rand.float32_range(2,8)}
			p:particle={
				velocity={rand.float32_range(-100+g.player.ph_data.size*-1,100+g.player.ph_data.size),rand.float32_range(-100+g.player.ph_data.size*-1,100+g.player.ph_data.size),0},
				pos={g.player.ph_data.pos.x+rand.float32_range(g.player.ph_data.size/-2,g.player.ph_data.size/2),g.player.ph_data.pos.y+rand.float32_range(g.player.ph_data.size/-2,g.player.ph_data.size/2),0},
				life=temp_life,
				max_life=temp_life,
				img=.B_Block,
				w_h=temp_wh,
				w_h_shift={temp_wh.x*-temp_life,temp_wh.y*-temp_life},
				tint={1,rand.float32_range(.0,1),rand.float32_range(0,.3),rand.float32_range(.8,1)},
				rot=rand.float32_range(0,360),
				rot_shift=rand.float32_range(-50,50),
			}

		add_particle(p)
		// play_sound(.explosion,.25)
		play_sound(.wa_wa,.025,2.5)
		}
	}
	if !g.player.ph_data.is_alive{
		if rl.IsKeyPressed(.ENTER)||rl.IsMouseButtonPressed(.LEFT)||rl.IsMouseButtonPressed(.RIGHT)||rl.IsKeyPressed(.SPACE)||rl.IsKeyPressed(.LEFT_SHIFT)||rl.IsKeyPressed(.RIGHT_SHIFT)||rl.IsKeyDown(.W)||rl.IsKeyDown(.S)||rl.IsKeyDown(.UP)||rl.IsKeyDown(.DOWN){
			restart_game()
		}
	}

	if rl.GetScreenWidth()<100{
		t_size_m=.25
	}
	if rl.GetScreenWidth()>300{
		t_size_m=.5
	}
	if rl.GetScreenWidth()>900{
		t_size_m=1
	}
	if rl.GetScreenWidth()>3000{
		t_size_m=2.5
	}
	if rl.GetScreenWidth()>4000{
		t_size_m=3
	}
	if rl.GetScreenWidth()>6000{
		t_size_m=4
	}
	if rl.GetScreenWidth()>9000{
		t_size_m=6
	}
	
}
check_if_player_is_in_bounds::proc(){
	if g.player.ph_data.pos.x>max_cam_dist*4||g.player.ph_data.pos.x<-max_cam_dist*4{
		g.player.ph_data.is_alive = false
		g.st.was_lost_in_space=true
	}
	if g.player.ph_data.pos.y>max_cam_dist*2.5||g.player.ph_data.pos.y<-max_cam_dist*2.5{
		g.player.ph_data.is_alive = false
		g.st.was_lost_in_space=true
	}

}

planit_grav:f32=50*2
thruster_strangth:f32=1.5
planit_size:f32:512*3
planit_rot:f32

kill_player::proc(){
	g.player.ph_data.is_alive=false
}



tick_physics_object::proc(object:^physics_object){

	if object.is_alive{
		mag:=mag_vec(-object.pos)

		object.rot+=object.rot_speed
		
		if mag <planit_size/2+object.size/2{
			object.is_alive = false
			g.astroids_count-=1
			for i in 0..<100+cast(i32)object.size+rand.int31_max(100) {
				temp_life:=rand.float32_range(.4,.6)
				temp_wh:[2]f32={rand.float32_range(2,8),rand.float32_range(2,8)}
				p:particle={
					velocity={rand.float32_range(-100+object.size*-1,100+object.size),rand.float32_range(-100+object.size*-1,100+object.size),0},
					pos={object.pos.x+rand.float32_range(object.size/-2,object.size/2),object.pos.y+rand.float32_range(object.size/-2,object.size/2),0},
					life=temp_life,
					max_life=temp_life,
					img=.B_Block,
					w_h=temp_wh,
					w_h_shift={temp_wh.x*-temp_life,temp_wh.y*-temp_life},
					tint={1,rand.float32_range(.0,1),rand.float32_range(0,.3),rand.float32_range(.8,1)},
					rot=rand.float32_range(0,360),
					rot_shift=rand.float32_range(-50,50),
				}
			add_particle(p)
			}
			play_sound(.explosion,.25)
		}
		norm_vec:[2]f32=normalise_vec(-object.pos)
		object.velocity+=norm_vec
		object.velocity*=0.9995
		object.pos+=object.velocity*planit_grav/(mag)

		dist_to_player:=get_distance(object.pos,g.player.ph_data.pos)
		
		if dist_to_player<g.player.ph_data.size/2+object.size/2&&object.pos!=g.player.ph_data.pos{
			object.is_alive = false
			g.astroids_count-=1
			for i in 0..<100+cast(i32)object.size+rand.int31_max(100) {
				temp_life:=rand.float32_range(.4,.6)
				temp_wh:[2]f32={rand.float32_range(2,8),rand.float32_range(2,8)}
				p:particle={
					velocity={rand.float32_range(-100+object.size*-1,100+object.size),rand.float32_range(-100+object.size*-1,100+object.size),0},
					pos={object.pos.x+rand.float32_range(object.size/-2,object.size/2),object.pos.y+rand.float32_range(object.size/-2,object.size/2),0},
					life=temp_life,
					max_life=temp_life,
					img=.B_Block,
					w_h=temp_wh,
					w_h_shift={temp_wh.x*-temp_life,temp_wh.y*-temp_life},
					tint={1,rand.float32_range(.0,1),rand.float32_range(0,.3),rand.float32_range(.8,1)},
					rot=rand.float32_range(0,360),
					rot_shift=rand.float32_range(-50,50),
				}
			add_particle(p)
			}
			g.player.ph_data.is_alive=false
		}
	}
	
}
tick_player_player::proc(){

	p_data:=&g.st.player.ph_data
	mag:=mag_vec(-p_data.pos)

	if g.player.ph_data.is_alive{
		if rl.IsKeyDown(.SPACE)||(rl.IsMouseButtonDown(.LEFT)&&!g.st.overide_left_click)||rl.IsKeyDown(.W)||rl.IsKeyDown(.UP){
			v_mag:=mag_vec(p_data.velocity)
			p_data.velocity += normalise_vec(p_data.velocity)*thruster_strangth
			if g.thruster_sound_cd<=0{
				play_sound(.thruster_2,rand.float32_range(.01,.05),rand.float32_range(.4,.6))
				if rand.float32_range(0,1) > .5{
					play_sound(.explosion,rand.float32_range(.01,.05),rand.float32_range(.4,.6))
				}
				// play_sound(.thruster_1,.05,.5)
				g.thruster_sound_cd = .1
			}


			for i in 0..<rand.int31_max(30) {
				temp_life:=rand.float32_range(.4,.6)
				temp_wh:[2]f32={rand.float32_range(2,8),rand.float32_range(2,8)}
				p:particle={
					velocity={rand.float32_range(-30,30),rand.float32_range(-30,30),0},
					pos={p_data.pos.x+rand.float32_range(-3,3),p_data.pos.y+rand.float32_range(-3,3),0},
					life=temp_life,
					max_life=temp_life,
					img=.B_Block,
					w_h=temp_wh,
					w_h_shift={temp_wh.x*-temp_life,temp_wh.y*-temp_life},
					tint={1,rand.float32_range(.0,1),rand.float32_range(0,.3),rand.float32_range(.8,1)},
					rot=rand.float32_range(0,360),
					rot_shift=rand.float32_range(-50,50),
				}
				add_particle(p)
			}
			temp_life:=rand.float32_range(.4,.6)
			temp_wh:[2]f32={rand.float32_range(2,8),rand.float32_range(2,8)}
			temp_velocity:=normalise_vec({p_data.velocity.x,p_data.velocity.y})
			p:particle={
				velocity={temp_velocity.y*100,temp_velocity.x*-100,0},
				pos={p_data.pos.x+rand.float32_range(-3,3),p_data.pos.y+rand.float32_range(-3,3),0},
				life=temp_life,
				max_life=temp_life,
				img=.B_Block,
				w_h=temp_wh,
				w_h_shift={temp_wh.x*-temp_life,temp_wh.y*-temp_life},
				tint={1,rand.float32_range(.0,1),rand.float32_range(0,.3),rand.float32_range(.8,1)},
				rot=rand.float32_range(0,360),
				rot_shift=rand.float32_range(-50,50),
			}
			add_particle(p)
			p.velocity={temp_velocity.y*-100,temp_velocity.x*100,0}
			add_particle(p)
		}
	}
	if g.player.ph_data.is_alive{
		if rl.IsKeyDown(.LEFT_SHIFT)||rl.IsMouseButtonDown(.RIGHT)||rl.IsKeyDown(.RIGHT_SHIFT)||rl.IsKeyDown(.S)||rl.IsKeyDown(.DOWN){
			// v_mag:=mag_vec(p_data.velocity)
			// p_data.velocity -= normalise_vec(p_data.velocity)*(thruster_strangth/1.85)
			// if g.thruster_sound_cd<=0{
			// 	// play_sound(.thruster_2,.1,rand.float32_range(1,1.5))
		
			// 	play_sound(.thruster_1,rand.float32_range(.01,.05),rand.float32_range(2,3))
			// 	g.thruster_sound_cd = .1
			// }
			// temp_life:=rand.float32_range(.4,.6)
			// temp_wh:[2]f32={rand.float32_range(2,8),rand.float32_range(2,8)}
			// temp_velocity:=normalise_vec({p_data.velocity.x,p_data.velocity.y})//+normalise_vec({-p_data.velocity.x,-p_data.velocity.y})
			// p:particle={
			// 	velocity={temp_velocity.y*100,temp_velocity.x*-100,0},
			// 	pos={p_data.pos.x+rand.float32_range(-3,3),p_data.pos.y+rand.float32_range(-3,3),0},
			// 	life=temp_life,
			// 	max_life=temp_life,
			// 	img=.B_Block,
			// 	w_h=temp_wh,
			// 	w_h_shift={temp_wh.x*-temp_life,temp_wh.y*-temp_life},
			// 	tint={1,rand.float32_range(.0,1),rand.float32_range(0,.3),rand.float32_range(.8,1)},
			// 	rot=rand.float32_range(0,360),
			// 	rot_shift=rand.float32_range(-50,50),
			// }
			// add_particle(p)
			// p.velocity={temp_velocity.y*-100,temp_velocity.x*100,0}
			// add_particle(p)
			slow_player()
		}


	}
	g.thruster_sound_cd-=rand.float32_range(.005,.02)
}
slow_player::proc(){
	p_data:=&g.st.player.ph_data
	v_mag:=mag_vec(p_data.velocity)
	p_data.velocity -= normalise_vec(p_data.velocity)*(thruster_strangth/1.85)
	if g.thruster_sound_cd<=0{
		// play_sound(.thruster_2,.1,rand.float32_range(1,1.5))

		play_sound(.thruster_1,rand.float32_range(.01,.05),rand.float32_range(2,3))
		g.thruster_sound_cd = .1
	}
	temp_life:=rand.float32_range(.4,.6)
	temp_wh:[2]f32={rand.float32_range(2,8),rand.float32_range(2,8)}
	temp_velocity:=normalise_vec({p_data.velocity.x,p_data.velocity.y})//+normalise_vec({-p_data.velocity.x,-p_data.velocity.y})
	p:particle={
		velocity={temp_velocity.y*100,temp_velocity.x*-100,0},
		pos={p_data.pos.x+rand.float32_range(-3,3),p_data.pos.y+rand.float32_range(-3,3),0},
		life=temp_life,
		max_life=temp_life,
		img=.B_Block,
		w_h=temp_wh,
		w_h_shift={temp_wh.x*-temp_life,temp_wh.y*-temp_life},
		tint={1,rand.float32_range(.0,1),rand.float32_range(0,.3),rand.float32_range(.8,1)},
		rot=rand.float32_range(0,360),
		rot_shift=rand.float32_range(-50,50),
	}
	add_particle(p)
	p.velocity={temp_velocity.y*-100,temp_velocity.x*100,0}
	add_particle(p)
}

normalise_vec::proc(vec:[2]f32)->(norm_vec:[2]f32){
	

	mag:=mag_vec(vec)
	if mag > 0{
		norm_vec={vec.x/mag,vec.y/mag}
	}else{
		norm_vec={0,0}
	}
	return
}
mag_vec::proc(vec:[2]f32)->(mag:f32){
	mag=math.sqrt(vec.x*vec.x+vec.y*vec.y)
	return
}

max_cam_dist::500+planit_size
draw :: proc() {

	n_cam_t:[3]f32=g.cam.target
	if g.player.ph_data.pos.x <max_cam_dist && g.player.ph_data.pos.x >-max_cam_dist{
		// n_cam_t[0]=g.player.ph_data.pos.x
		animate_to_target_f32(&n_cam_t[0],g.player.ph_data.pos.x,g.time.dt)
	}
	if g.player.ph_data.pos.y <max_cam_dist && g.player.ph_data.pos.y >-max_cam_dist{
		// n_cam_t[1]=g.player.ph_data.pos.y
		animate_to_target_f32(&n_cam_t[1],g.player.ph_data.pos.y,g.time.dt)
	}
	n_cam_t[2]=-50
	g.cam.position = n_cam_t
	n_cam_t[2]=0
	g.cam.target = n_cam_t          
	rl.BeginDrawing()
	rl.ClearBackground({0, 5, 30,255})
	rl.BeginMode3D(g.cam)//g.cam
	rl.BeginShaderMode(g.as.shaders.bace)

	rl.BeginBlendMode(.ADDITIVE)
	draw_particles()
	rl.EndBlendMode()

	// draw_by_id_3d(.Green_Planet,{0,0,planit_size,planit_size},0,{planit_size/2,planit_size/2},planit_rot)
	temp_p_size:=planit_size
	if g.st.planit_img == .White_Stare||g.st.planit_img == .Yelow_Stare{
		temp_p_size *=2
	}
	if g.st.planit_img == .Gass_2_Planit{
		temp_p_size *=3
	}
	draw_animation(g.st.planit_img,{0,0,temp_p_size,temp_p_size},0,{temp_p_size/2,temp_p_size/2},planit_rot)

	nor_player_vec:=normalise_vec(g.st.player.ph_data.velocity)
	if g.player.ph_data.is_alive{
		draw_by_id_3d(.Ship_1,{g.st.player.ph_data.pos.x,g.st.player.ph_data.pos.y,64,64},0,{64/2,64/2},rot=-((math.atan2(nor_player_vec.x,nor_player_vec.y)) * (180 / math.PI)))
	}
	// rl.DrawModel(modle,{0,0,0},16,{255,255,255,255})
	for &obj in &g.physics_object{
		draw_physics_object(&obj)
	}

	rl.EndShaderMode()
	rl.EndMode3D()

	rl.BeginMode2D(ui_camera())

	clayRaylibRender(&ui_render_command)
	rl.EndMode2D()

	// rl.DrawFPS(10,10)
	rl.EndDrawing()
}

draw_physics_object::proc(obj:^physics_object){
	if obj.is_alive{
		nor_obj_vec:=normalise_vec(obj.velocity)
		draw_by_id_3d(obj.img,{obj.pos.x,obj.pos.y,obj.size,obj.size},0,{obj.size/2,obj.size/2},rot=-((math.atan2(nor_obj_vec.x,nor_obj_vec.y)) * (180 / math.PI))+obj.rot)	
	}
}
spawn_astroid::proc(){
	for &obj in &g.physics_object{
		if !obj.is_alive{
			obj.is_alive=true
			obj_x:f32
			obj_y:f32
			if g.player.ph_data.pos.x >0{
				obj_x=-1
			}else{
				obj_x=1
			}
			if g.player.ph_data.pos.y >0{
				obj_y=-1
			}else{
				obj_y=1
			}
			obj.img=.Small_P_Astroid
			if rand.float32_range(0,1)>.85{
				obj.img=.Small_P_Moon_2
			}
			if rand.float32_range(0,1)>.85{
				obj.img=.Small_P_Moon_1
			}
			if rand.float32_range(0,1)>.90{
				obj.img=.Small_P_Gass_1
			}
			if rand.float32_range(0,1)>.90{
				obj.img=.Small_P_Dry
			}
			if rand.float32_range(0,1)>.90{
				obj.img=.Small_P_Lava
			}
			if rand.float32_range(0,1)>.90{
				obj.img=.Small_P_Ice
			}
			if rand.float32_range(0,1)>.99{
				obj.img=.Small_P_Island
			}
			if rand.float32_range(0,1)>.95{
				obj.img=.Ice
			}
			if rand.float32_range(0,1)>.95{
				obj.img=.Lava
			}
			if rand.float32_range(0,1)>.99{
				obj.img=.Terran
			}
			temp_v:[2]f32
			if rand.float32_range(0,1)>.5{
				temp_v={-obj_x*rand.float32_range((planit_size/5),(planit_size/3)),obj_y*rand.float32_range((-planit_size/5),(planit_size/3))}
			}else{
				temp_v={obj_x*rand.float32_range((planit_size/5),(planit_size/3)),-obj_y*rand.float32_range((-planit_size/5),(planit_size/3))}
			}
			obj.size=rand.float32_range(32,256)
			obj.rot=rand.float32_range(0,360)
			obj.rot_speed=rand.float32_range(-5,5)
			obj.pos={obj_x*rand.float32_range(100+planit_size,800+planit_size),obj_y*rand.float32_range(100+planit_size,800+planit_size)}
			obj.velocity=temp_v
			g.astroids_count+=1
			return
		}
	}
}
maintanin_astroid_numbers::proc(){
	if g.st.max_astroids > g.astroids_count{
		spawn_astroid()
	}
}
max_stars::2000
mainrain_stars::proc(){
	for max_stars > g.star_count{
			life:=rand.float32_range(10,50)
			size:=rand.float32_range(5,15)
			p:particle={
				origin_offset={size/2,size/2},
				velocity={rand.float32_range(-5,-2),rand.float32_range(-5,2),0},
				pos={rand.float32_range(-8000,8000),rand.float32_range(-5000,5000),0},
				life=life,
				max_life=life,
				img=.B_Block,
				w_h={size,size},
				w_h_shift={-size/life/2,-size/life/2},
				tint={rand.float32_range(.9,1),rand.float32_range(.5,1),rand.float32_range(.5,1),rand.float32_range(.5,1)},
				rot=rand.float32_range(0,360),
				rot_shift=rand.float32_range(-50,50),
				destroy_callback=destroy_stare,
			}
			add_particle(p)
			g.star_count+=1
	}
}
destroy_stare::proc(p:^particle){
	g.star_count-=1
}
maintanin_score::proc(){

	if !g.temp_score_cros{
		if g.player.ph_data.pos.x >0{
			g.temp_score_cros = true
			g.score+=1
			g.max_astroids+=1
			play_sound(.pickupcoin,.5)
		}else{

		}
	}else{
		if g.player.ph_data.pos.x >0{
		
		}else{
			g.temp_score_cros = false
		}
	}
}

ui_camera :: proc() -> rl.Camera2D {
	return {
		// zoom = f32(rl.GetScreenHeight())/PIXEL_WINDOW_HEIGHT,
		zoom = 1
	}
}
