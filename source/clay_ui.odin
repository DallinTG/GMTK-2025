package game

import "core:fmt"
import "core:math/linalg"
import "core:math"
import rl "vendor:raylib"
import noise"core:math/noise"
import clay "/clay-odin"
import "base:runtime"

ui_render_command:clay.ClayArray(clay.RenderCommand)

// Define some colors.
font_color::clay.Color{10, 10, 10, 255}
COLOR_LIGHT :: clay.Color{224, 215, 210, 255}
c_red :: clay.Color{108, 103, 130, 155}
c_red_hov :: clay.Color{108, 103, 130, 255}
COLOR_ORANGE :: clay.Color{225, 138, 50, 255}
COLOR_BLACK :: clay.Color{0, 0, 0, 255}

ui_pages::enum{
    start,
    mode_sulect,
    game,
    setings,
}
ui_page_data::struct{
    id:ui_pages,
    is_open:bool,
    current_offset:[2]f32,
}
ui_state::struct{
    pages:[ui_pages]ui_page_data,
}




// Layout config is just a struct that can be declared statically, or inline

error_handler :: proc "c" (errorData: clay.ErrorData) {
    // Do something with the error data.
}
init_clay_ui::proc(){
    min_memory_size: u32 = clay.MinMemorySize()
    memory := make([^]u8, min_memory_size)
    arena: clay.Arena = clay.CreateArenaWithCapacityAndMemory(auto_cast min_memory_size, memory)
    clay.Initialize(arena, { width = 720, height = 720 }, { handler = error_handler })
    // clay.SetMeasureTextFunction(measureText,nil)
    clay.SetMeasureTextFunction(measureText,nil)
    // loadFont(FONT_ID_TITLE_56, 56, "resources/Calistoga-Regular.ttf")
    raylibFonts[1].font = rl.GetFontDefault()
    raylibFonts[1].fontId = 1
    raylibFonts[0].font = rl.GetFontDefault()
    raylibFonts[0].fontId = 1
}
update_clay_ui::proc(){
    mouse_pos:= rl.GetMousePosition()
    is_mouse_down:=rl.IsMouseButtonDown(.LEFT)
    clay.SetPointerState(
        clay.Vector2 { mouse_pos.x, mouse_pos.y },
        is_mouse_down,
    )
    clay.UpdateScrollContainers(false, transmute(clay.Vector2)rl.GetMouseWheelMoveV(), rl.GetFrameTime())
    clay.SetLayoutDimensions({auto_cast g.window_info.w,auto_cast g.window_info.h})
    ui_render_command = create_ui_layout()

}
t_size_m:f32=1


// An example function to create your layout tree
create_ui_layout :: proc() -> clay.ClayArray(clay.RenderCommand) {

    g.st.overide_left_click=false

    clay.BeginLayout()

     if clay.UI()({
        id = clay.ID("outOuterContainer"),
        layout = {
            sizing = { width = clay.SizingGrow({}), height = clay.SizingGrow({}) },
            padding = { 16, 16, 16, 16 },
            childGap = 0,
            layoutDirection=.TopToBottom,

        },
        backgroundColor = { 0, 0, 0, 0 },
    }) 
    {
    

        if clay.UI()({
            id = clay.ID("topOuterContainer"),
            layout = {
                sizing = { width = clay.SizingGrow({}), height = clay.SizingGrow({}) },
                // padding = { 16, 16, 16, 16 },
                childGap = 0,
            },
            backgroundColor = { 0, 0, 0, 0 },
        }) {
            if clay.UI()({
                id = clay.ID("LeftContainer"),
                layout = {
                    sizing = { width = clay.SizingGrow({}), height = clay.SizingGrow({}) },
                    // padding = { 16, 16, 16, 16 },
                    childGap = 16,
                },
                backgroundColor = { 255, 0, 0, 0 },
            }){}
            if clay.UI()({
                id = clay.ID("midContainer"),
                layout = {
                    sizing = { width = clay.SizingGrow({}), height = clay.SizingGrow({}) },
                    // padding = { 16, 16, 16, 16 },
                    childGap = 16,
                    childAlignment={x=.Center},
                    layoutDirection=.TopToBottom,
                },
                backgroundColor = { 0, 255, 0, 0 },
            }){
                if clay.UI()({
                    id = clay.ID("scoreContainer"),
                    layout = {
                        sizing = { width = clay.SizingFit({}), height = clay.SizingFit({}) },
                        padding = { 6, 6, 6, 6 },
                        childGap = 16,
                        childAlignment={x=.Center},
                        layoutDirection=.TopToBottom,
                        
                    },
                    cornerRadius={5,5,5,5},
                    backgroundColor = { 30, 30, 60, 255 },
                }){
                    if g.st.player.ph_data.is_alive{
                        clay.TextDynamic(
                            fmt.tprint("Score:",g.st.score),
                            &{
                                textColor={255,255,255,255},
                                fontSize=cast(u16)(25*t_size_m),
                                letterSpacing=cast(u16)(4*t_size_m),
                            },
                        )
                    }else{
                    
                    	if g.h_score<g.st.score{
                            clay.TextDynamic(
                                fmt.tprint("New High Score:",g.st.score),
                                &{
                                    textColor={255,255,255,255},
                                    fontSize=cast(u16)(25*t_size_m),
                                    letterSpacing=cast(u16)(4*t_size_m),
                                },
                            )
                            clay.TextDynamic(
                                fmt.tprint("Last High Score:",g.h_score),
                                &{
                                    textColor={255,255,255,255},
                                    fontSize=cast(u16)(25*t_size_m),
                                    letterSpacing=cast(u16)(4*t_size_m),
                                },
                            )
	                    }else{
                                                        clay.TextDynamic(
                                fmt.tprint("Score:",g.st.score),
                                &{
                                    textColor={255,255,255,255},
                                    fontSize=cast(u16)(25*t_size_m),
                                    letterSpacing=cast(u16)(4*t_size_m),
                                },
                            )
                            clay.TextDynamic(
                                fmt.tprint("High Score:",g.h_score),
                                &{
                                    textColor={255,255,255,255},
                                    fontSize=cast(u16)(25*t_size_m),
                                    letterSpacing=cast(u16)(4*t_size_m),
                                },
                            )
                        }
                    }
                }
                
            }
            if clay.UI()({
                id = clay.ID("RightContainer"),
                layout = {
                    sizing = { width = clay.SizingGrow({}), height = clay.SizingGrow({}) },
                    // padding = { 16, 16, 16, 16 },
                    childGap = 16,
                },
                backgroundColor = { 0, 0, 255, 0 },
            }){}
        }



        if clay.UI()({
            id = clay.ID("BotOuterContainer"),
            layout = {
                sizing = { width = clay.SizingGrow({}), height = clay.SizingGrow({}) },
                // padding = { 16, 16, 16, 16 },
                childGap = 0,
            },
            backgroundColor = { 0, 0, 0, 0 },
        }) {
            if clay.UI()({
                id = clay.ID("LeftContainer"),
                layout = {
                    sizing = { width = clay.SizingGrow({}), height = clay.SizingGrow({}) },
                    // padding = { 16, 16, 16, 16 },
                    childGap = 16,
                },
                backgroundColor = { 255, 0, 0, 0 },
            }){}
            if clay.UI()({
                id = clay.ID("midContainer"),
                layout = {
                    sizing = { width = clay.SizingGrow({}), height = clay.SizingGrow({}) },
                    // padding = { 16, 16, 16, 16 },
                    childGap = 16,
                    layoutDirection=.TopToBottom,
                },
                backgroundColor = { 0, 255, 0, 0 },
            }){
                if !g.player.ph_data.is_alive{
                    if clay.UI()({
                        id = clay.ID("game_over_Container"),
                        layout = {
                            sizing = { width = clay.SizingGrow({}), height = clay.SizingFit({}) },
                            padding = { 16, 16, 16, 16 },
                            childGap = 16,
                            layoutDirection=.TopToBottom,
                            childAlignment={x=.Center},
                        },
                        cornerRadius={5,5,5,5},
                        backgroundColor = { 60, 60, 90, 155 },
                    }){
                    clay.TextDynamic(
                        fmt.tprint("WA WA Game Over"),
                        &{
                            textColor={255,55,55,255},
                            fontSize=cast(u16)(25*t_size_m),
                            letterSpacing=cast(u16)(4*t_size_m),
                            textAlignment=.Center,
                        },
                    )
                    if g.st.was_lost_in_space{
                        clay.TextDynamic(
                        fmt.tprint("LOL You Got Lost In Deep Space"),
                        &{
                            textColor={255,255,255,255},
                            fontSize=cast(u16)(25*t_size_m),
                            letterSpacing=cast(u16)(4*t_size_m),
                            textAlignment=.Center,
                        },
                    )
                    }
                    if g.st.score<1{
                        clay.TextDynamic(
                        fmt.tprint("LOL How Are You So Bad You Didn't Even Get One Point"),
                        &{
                            textColor={255,255,255,255},
                            fontSize=cast(u16)(25*t_size_m),
                            letterSpacing=cast(u16)(4*t_size_m),
                            textAlignment=.Center,
                        },
                        )
                    }
                    if g.h_score<g.st.score{
                        clay.TextDynamic(
                        fmt.tprint("You Got A New High Score Good Job"),
                        &{
                            textColor={255,255,255,255},
                            fontSize=cast(u16)(25*t_size_m),
                            letterSpacing=cast(u16)(4*t_size_m),
                            textAlignment=.Center,
                        },
                        )
                    }
                    if g.st.rand_number>.9&&g.st.rand_number<1{
                        clay.TextDynamic(
                        fmt.tprint("Technoblade Never Dies Butt You Did. Looser"),
                        &{
                            textColor={255,255,255,255},
                            fontSize=cast(u16)(25*t_size_m),
                            letterSpacing=cast(u16)(4*t_size_m),
                            textAlignment=.Center,
                        },
                        )
                    }
                    if g.st.rand_number>.8&&g.st.rand_number<.9{
                        clay.TextDynamic(
                        fmt.tprint("Blood For The Blood God"),
                        &{
                            textColor={255,55,55,255},
                            fontSize=cast(u16)(25*t_size_m),
                            letterSpacing=cast(u16)(4*t_size_m),
                            textAlignment=.Center,
                        },
                        )
                    }
                    if g.st.rand_number>.7&&g.st.rand_number<.8{
                        clay.TextDynamic(
                        fmt.tprint("HA HA HA HA HA HA HA HA HA HA HA YOU ARE TRASH"),
                        &{
                            textColor={255,55,55,255},
                            fontSize=cast(u16)(25*t_size_m),
                            letterSpacing=cast(u16)(4*t_size_m),
                            textAlignment=.Center,
                        },
                        )
                    }
                    if g.st.rand_number>.6&&g.st.rand_number<.7{
                        clay.TextDynamic(
                        fmt.tprint("Get Good Kid"),
                        &{
                            textColor={255,255,255,255},
                            fontSize=cast(u16)(25*t_size_m),
                            letterSpacing=cast(u16)(4*t_size_m),
                            textAlignment=.Center,
                        },
                        )
                    }
                    if g.st.rand_number>.5&&g.st.rand_number<.6{
                        clay.TextDynamic(
                        fmt.tprint("You Killed Kenny"),
                        &{
                            textColor={255,100,0,255},
                            fontSize=cast(u16)(25*t_size_m),
                            letterSpacing=cast(u16)(4*t_size_m),
                            textAlignment=.Center,
                        },
                        )
                    }
                    if g.st.rand_number>.4&&g.st.rand_number<.5{
                        clay.TextDynamic(
                        fmt.tprint("Well I just killed A Small Child"),
                        &{
                            textColor={255,255,255,255},
                            fontSize=cast(u16)(25*t_size_m),
                            letterSpacing=cast(u16)(4*t_size_m),
                            textAlignment=.Center,
                        },
                        )
                    }
                    if g.st.rand_number>.3&&g.st.rand_number<.4{
                        clay.TextDynamic(
                        fmt.tprint("Take That, Orphans."),
                        &{
                            textColor={255,255,255,255},
                            fontSize=cast(u16)(25*t_size_m),
                            letterSpacing=cast(u16)(4*t_size_m),
                            textAlignment=.Center,
                        },
                        )
                    }
                    if g.st.rand_number>.2&&g.st.rand_number<.3{
                        clay.TextDynamic(
                        fmt.tprint("Peer Pressure, Peer Pressure."),
                        &{
                            textColor={255,255,255,255},
                            fontSize=cast(u16)(25*t_size_m),
                            letterSpacing=cast(u16)(4*t_size_m),
                            textAlignment=.Center,
                        },
                        )
                    }
                    if g.st.rand_number>.1&&g.st.rand_number<.2{
                        clay.TextDynamic(
                        fmt.tprint("Id Wish You The Best Of Luck, But I Believe Luck Is A Concept Created By The Weak To Explain Their Failures."),
                        &{
                            textColor={255,255,255,255},
                            fontSize=cast(u16)(25*t_size_m),
                            letterSpacing=cast(u16)(4*t_size_m),
                            textAlignment=.Center,
                        },
                        )
                    }
                    if g.st.rand_number>.0&&g.st.rand_number<.1{
                        clay.TextDynamic(
                        fmt.tprint("You Had Me At Meat Tornado."),
                        &{
                            textColor={255,255,255,255},
                            fontSize=cast(u16)(25*t_size_m),
                            letterSpacing=cast(u16)(4*t_size_m),
                            textAlignment=.Center,
                        },
                        )
                    }
                    clay.TextDynamic(
                        fmt.tprint("Press Any Button To Restart"),
                        &{
                            textColor={255,255,255,255},
                            fontSize=cast(u16)(20*t_size_m),
                            letterSpacing=cast(u16)(3*t_size_m),
                            textAlignment=.Center,
                        },
                    )
                }
                }
                if g.st.player.ph_data.is_alive&&rl.GetScreenHeight()>rl.GetScreenWidth(){
                    if clay.UI()({
                        id = clay.ID("pading"),
                        layout = {
                            sizing = { width = clay.SizingGrow({}), height = clay.SizingGrow({}) },
                            padding = { 16, 16, 16, 16 },
                            childGap = 16,
                            layoutDirection=.TopToBottom,
                            childAlignment={x=.Center},
                        },
                        cornerRadius={5,5,5,5},
                        backgroundColor = { 60, 60, 90, 0 },
                    }){

                    }
                    if clay.UI()({
                        id = clay.ID("speed_contaner"),
                        layout = {
                            sizing = { width = clay.SizingGrow({}), height = clay.SizingGrow({}) },
                            padding = { 16, 16, 16, 16 },
                            childGap = 16,
                            layoutDirection=.TopToBottom,
                            childAlignment={x=.Center,y=.Center},
                        },
                        cornerRadius={5,5,5,5},
                        backgroundColor = clay.Hovered()?{ 60, 60, 90, 255 }:{ 60, 60, 90, 155 },
                    }){
                        clay.TextDynamic(
                            fmt.tprint("[SLOW]"),
                            &{
                                textColor={255,255,255,255},
                                fontSize=cast(u16)(40*t_size_m),
                                letterSpacing=cast(u16)(6*t_size_m),
                                textAlignment=.Center,
                            },
                        )
                        if clay.Hovered(){
                            if rl.IsMouseButtonDown(.LEFT){
                                g.st.overide_left_click=true
                                if g.time.is_60h_this_frame{
                                    slow_player()
                                }
                            }
                        }
                    }
                }
            }
            if clay.UI()({
                id = clay.ID("RightContainer"),
                layout = {
                    sizing = { width = clay.SizingGrow({}), height = clay.SizingGrow({}) },
                    // padding = { 16, 16, 16, 16 },
                    childGap = 16,
                },
                backgroundColor = { 0, 0, 255, 0 },
            }){}
        }
    }
    // Returns a list of render commands
    render_commands: clay.ClayArray(clay.RenderCommand) = clay.EndLayout()
    return render_commands
}

ui_page::proc(pd:^ui_page_data){
    if clay.UI()({
        id = clay.ID(fmt.tprint(pd.id)),
        layout = {
            sizing = { width = clay.SizingGrow({}), height = clay.SizingGrow({}) },
            // padding = { 16, 16, 16, 16 },
            childGap = 16,
        },
        floating={offset=pd.current_offset,attachTo = .Parent},
        backgroundColor = { 0, 255, 255, 255 },
    }){
        if clay.Hovered(){
            if rl.IsMouseButtonDown(.LEFT){
                pd.current_offset+=rl.GetMouseDelta()
            }
        }
        b_box:=clay.GetElementData(clay.GetElementId(clay.MakeString(fmt.tprint(pd.id)))).boundingBox
        if b_box.x<0{
            pd.current_offset.x-=b_box.x
        }
        if b_box.x+b_box.width > cast(f32)g.window_info.w{
            pd.current_offset.x-=b_box.x+b_box.width-cast(f32)g.window_info.w
        }
        if b_box.y<0{
            pd.current_offset.y-=b_box.y
        }
        if b_box.y+b_box.height > cast(f32)g.window_info.h{
            pd.current_offset.y-=b_box.y+b_box.height-cast(f32)g.window_info.h
        }
    }
}






