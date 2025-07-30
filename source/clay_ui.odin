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



// An example function to create your layout tree
create_ui_layout :: proc() -> clay.ClayArray(clay.RenderCommand) {
    
    clay.BeginLayout()

    // if clay.UI()({
    //     id = clay.ID("OuterContainer"),
    //     layout = {
    //         sizing = { width = clay.SizingGrow({}), height = clay.SizingGrow({}) },
    //         padding = { 16, 16, 16, 16 },
    //         childGap = 0,
    //     },
    //     backgroundColor = { 0, 0, 0, 0 },
    // }) {
    //     if clay.UI()({
    //         id = clay.ID("LeftContainer"),
    //         layout = {
    //             sizing = { width = clay.SizingGrow({}), height = clay.SizingGrow({}) },
    //             padding = { 16, 16, 16, 16 },
    //             childGap = 16,
    //         },
    //         backgroundColor = { 255, 0, 0, 55 },
    //     }){}
    //     if clay.UI()({
    //         id = clay.ID("midContainer"),
    //         layout = {
    //             sizing = { width = clay.SizingGrow({}), height = clay.SizingGrow({}) },
    //             padding = { 16, 16, 16, 16 },
    //             childGap = 16,
    //         },
    //         backgroundColor = { 0, 255, 0, 55 },
    //     }){
    //         ui_page(&g.ui_st.pages[.start])
    //     }
    //     if clay.UI()({
    //         id = clay.ID("RightContainer"),
    //         layout = {
    //             sizing = { width = clay.SizingGrow({}), height = clay.SizingGrow({}) },
    //             padding = { 16, 16, 16, 16 },
    //             childGap = 16,
    //         },
    //         backgroundColor = { 0, 0, 255, 55 },
    //     }){}
    // }
    // Returns a list of render commands
    render_commands: clay.ClayArray(clay.RenderCommand) = clay.EndLayout()
    return render_commands
}

ui_page::proc(pd:^ui_page_data){
    if clay.UI()({
        id = clay.ID(fmt.tprint(pd.id)),
        layout = {
            sizing = { width = clay.SizingGrow({}), height = clay.SizingGrow({}) },
            padding = { 16, 16, 16, 16 },
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






