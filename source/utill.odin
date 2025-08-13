package game

import rl "vendor:raylib"
import "core:math"
import "core:math/rand"
import "core:fmt"

time_stuff::struct{
    dt:f32,
    dt_60h:f32,
    is_60h_this_frame:bool,
    frame_count_60h:i32,
    frame_count:uint,

}
window_info::struct{
    w:i32,
    h:i32,
}

frame_langth::0.016666  
maintain_timers::proc(){
    
    g.time.dt = rl.GetFrameTime()
    g.time.dt_60h += rl.GetFrameTime()
    g.time.frame_count+=1
    if g.time.is_60h_this_frame == true{
        g.time.is_60h_this_frame = false
        // g.time.dt_60h =0.0  
        g.time.dt_60h -=frame_langth   
    }
    if g.time.dt_60h >frame_langth{
        g.time.is_60h_this_frame = true
        g.time.frame_count_60h+=1
    }
}
lerp_colors::proc(c1:[4]f32,c2:[4]f32,m:f32)->(f_color:[4]f32){
    f_color ={ math.lerp(c1.r,c2.r,m),math.lerp(c1.g,c2.g,m),math.lerp(c1.b,c2.b,m),math.lerp(c1.a,c2.a,m)}
    return
}




do_inputs::proc(){
    check_cam_movements()
    check_paning()
    check_fov()
}
min_zoom::64
max_zoom::2048
tile_size::16
check_fov::proc(){
    g.cam.fovy +=rl.GetMouseWheelMove()*tile_size*-2
    if g.cam.fovy < min_zoom {g.cam.fovy = min_zoom}
    // if g.cam.fovy > max_zoom {g.cam.fovy = max_zoom}
}



check_cam_movements::proc(){
   

}


check_paning::proc(){
    
	if rl.IsMouseButtonDown(.RIGHT) {
        
		delta:rl.Vector2 = rl.GetMouseDelta()
		delta = (delta *(g.cam.fovy/cast(f32)rl.GetScreenHeight())*-1 )
		g.cam.position += {delta.x,delta.y,0}
		g.cam.target.x = g.cam.position.x
		g.cam.target.y = g.cam.position.y

	}
}

maintain_window_info::proc(){
    g.window_info.h=rl.GetScreenHeight()  
    g.window_info.w=rl.GetScreenWidth()

}

get_distance::proc(pos_1,pos_2:[2]f32)->(dist:f32){
    dist=math.sqrt((pos_1.x-pos_2.x)*(pos_1.x-pos_2.x)+(pos_1.y-pos_2.y)*(pos_1.y-pos_2.y))
    return
}
animate_to_target_v2 :: proc(value: ^[2]f32, target: [2]f32, delta_t: f32, rate :f32= 15.0, good_enough:f32= 0.001)
{
	animate_to_target_f32(&value.x, target.x, delta_t, rate, good_enough)
	animate_to_target_f32(&value.y, target.y, delta_t, rate, good_enough)
}

animate_to_target_f32 :: proc(value: ^f32, target: f32, delta_t: f32, rate:f32= 15.0, good_enough:f32= 0.001) -> bool
{
	value^ += (target - value^) * (1.0 - math.pow_f32(2.0, -rate * delta_t));
	if almost_equals(value^, target, good_enough)
	{
		value^ = target;
		return true; // reached
	}
	return false;
}

almost_equals :: proc(a: f32, b: f32, epsilon: f32 = 0.001) -> bool
{
	return abs(a - b) <= epsilon;
}
// get_distance::proc(pos1,pos2:[2]f32)->(dist:f32){
//     dist=math.sqrt((pos1.x-pos2.x)*(pos1.x-pos2.x)+(pos1.y-pos2.y)*(pos1.y-pos2.y))
//     return
// }