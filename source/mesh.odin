package game

import rl "vendor:raylib"
import rlgl "vendor:raylib/rlgl"
import fmt "core:fmt"
import "core:math"





gen_mesh_quad::proc(t_name:Texture_Name, w_h:[2]f32=1, at_w:f32=cast(f32)g.atlas.width, at_h:f32=cast(f32)g.atlas.height)->rl.Mesh{
    mesh:rl.Mesh 
    mesh.triangleCount = 2
    mesh.vertexCount = mesh.triangleCount*3

    mesh.vertices = make([^]f32, mesh.vertexCount * 3)
    mesh.texcoords = make([^]f32, mesh.vertexCount * 2)
    mesh.normals = make([^]f32, mesh.vertexCount * 3)

    t_rec:=atlas_textures[t_name].rect

    // top_left
    mesh.vertices[0] = 0*w_h.x
    mesh.vertices[1] = 0*w_h.y
    mesh.vertices[2] = 0
    mesh.normals[0] = 0
    mesh.normals[1] = 0
    mesh.normals[2] = 1
    // mesh.texcoords[0] = 0
    // mesh.texcoords[1] = 0

    mesh.texcoords[0] = t_rec.x/at_w
    mesh.texcoords[1] = t_rec.y/at_h

    // bot_left
    mesh.vertices[3] = 0*w_h.x
    mesh.vertices[4] = 1*w_h.y
    mesh.vertices[5] = 0
    mesh.normals[3] = 0
    mesh.normals[4] = 0
    mesh.normals[5] = 1
    // mesh.texcoords[2] = 0
    // mesh.texcoords[3] = 1

    mesh.texcoords[2] = t_rec.x/at_w
    mesh.texcoords[3] = (t_rec.y+t_rec.height)/at_h

    // top_right
    mesh.vertices[6] = 1*w_h.x
    mesh.vertices[7] = 0*w_h.y
    mesh.vertices[8] = 0
    mesh.normals[6] = 0
    mesh.normals[7] = 0
    mesh.normals[8] = 1
    // mesh.texcoords[4] = 1
    // mesh.texcoords[5] =0

    mesh.texcoords[4] = (t_rec.x+t_rec.width)/at_w
    mesh.texcoords[5] = t_rec.y/at_h



        // bot_right
    mesh.vertices[0+9] = 1*w_h.x
    mesh.vertices[1+9] = 1*w_h.y
    mesh.vertices[2+9] = 0
    mesh.normals[0+9] = 0
    mesh.normals[1+9] = 0
    mesh.normals[2+9] = 1
    // mesh.texcoords[0+6] = 1
    // mesh.texcoords[1+6] = 1

    mesh.texcoords[0+6] = (t_rec.x+t_rec.width)/at_w
    mesh.texcoords[1+6] = (t_rec.y+t_rec.height)/at_h

    // top_right
    mesh.vertices[3+9] = 1*w_h.x
    mesh.vertices[4+9] = 0*w_h.y
    mesh.vertices[5+9] = 0
    mesh.normals[3+9] = 0
    mesh.normals[4+9] = 0
    mesh.normals[5+9] = 1
    // mesh.texcoords[2+6] = 1
    // mesh.texcoords[3+6] = 0

    mesh.texcoords[2+6] = (t_rec.x+t_rec.width)/at_w
    mesh.texcoords[3+6] = t_rec.y/at_h

    // bot_left
    mesh.vertices[6+9] = 0*w_h.x
    mesh.vertices[7+9] = 1*w_h.y
    mesh.vertices[8+9] = 0
    mesh.normals[6+9] = 0
    mesh.normals[7+9] = 0
    mesh.normals[8+9] = 1
    // mesh.texcoords[4+6] = 0
    // mesh.texcoords[5+6] =1

    mesh.texcoords[4+6] = t_rec.x/at_w
    mesh.texcoords[5+6] = (t_rec.y+t_rec.height)/at_h

    // Upload mesh data from CPU (RAM) to GPU (VRAM) memory
    rl.UploadMesh(&mesh, false)

    return mesh
}


gen_mesh_tmap_bace::proc(tmap_w_h:[2]i32,t_name:Texture_Name, t_w_h:[2]f32=1, at_w:f32=cast(f32)g.atlas.width, at_h:f32=cast(f32)g.atlas.height)->rl.Mesh{
    tile_count:=tmap_w_h.x*tmap_w_h.y
    mesh:rl.Mesh 
    mesh.triangleCount = 2*tile_count
    mesh.vertexCount = mesh.triangleCount*3

    mesh.vertices = make([^]f32, mesh.vertexCount * 3)
    mesh.texcoords = make([^]f32, mesh.vertexCount * 2)
    mesh.normals = make([^]f32, mesh.vertexCount * 3)

    t_rec:=atlas_textures[t_name].rect

    tile_index:i32=0
    for row_x in 0..<tmap_w_h.x {
        for col_y in 0..<tmap_w_h.y {
            gen_single_tile_for_t_map(mesh=mesh ,tile_index=tile_index,t_rec=t_rec,t_w_h=t_w_h,row_x=row_x,col_y=col_y, at_w=at_w,at_h=at_h)
            tile_index+=1
        }
    }
    
    // Upload mesh data from CPU (RAM) to GPU (VRAM) memory
    rl.UploadMesh(&mesh, false)
    return mesh
}

gen_mesh_tmap::proc(t_data:[][]Texture_Name, t_w_h:[2]f32=1, at_w:f32=cast(f32)g.atlas.width, at_h:f32=cast(f32)g.atlas.height)->rl.Mesh{
    tile_count:=cast(i32)len(t_data)*cast(i32)len(t_data[0])
    mesh:rl.Mesh 
    mesh.triangleCount = 2*tile_count
    mesh.vertexCount = mesh.triangleCount*3

    mesh.vertices = make([^]f32, mesh.vertexCount * 3)
    mesh.texcoords = make([^]f32, mesh.vertexCount * 2)
    mesh.normals = make([^]f32, mesh.vertexCount * 3)

    tile_index:i32=0
    for row_data , row_x in t_data{
        for col_data , col_y in row_data {
            t_rec:=atlas_textures[t_data[row_x][col_y]].rect
            gen_single_tile_for_t_map(mesh=mesh ,tile_index=tile_index,t_rec=t_rec,t_w_h=t_w_h,row_x=cast(i32)row_x,col_y=cast(i32)col_y, at_w=at_w,at_h=at_h)
            tile_index+=1
        }
    }

    // Upload mesh data from CPU (RAM) to GPU (VRAM) memory
    rl.UploadMesh(&mesh, false)
    return mesh
}

gen_single_tile_for_t_map::proc(mesh:rl.Mesh ,tile_index:i32,t_rec:Rect,t_w_h:[2]f32=1,row_x:i32,col_y:i32, at_w:f32=cast(f32)g.atlas.width,at_h:f32=cast(f32)g.atlas.height){
    mesh.vertices[0+(18*tile_index)] = 0*t_w_h.x+(cast(f32)row_x*t_w_h.x)
    mesh.vertices[1+(18*tile_index)] = 0*t_w_h.y+(cast(f32)col_y*t_w_h.y)
    mesh.vertices[2+(18*tile_index)] = 0
    mesh.normals[0+(18*tile_index)] = 0
    mesh.normals[1+(18*tile_index)] = 0
    mesh.normals[2+(18*tile_index)] = 1

    mesh.texcoords[0+(+12*tile_index)] = t_rec.x/at_w
    mesh.texcoords[1+(+12*tile_index)] = t_rec.y/at_h


    // bot_left
    mesh.vertices[3+(18*tile_index)] = 0*t_w_h.x+(cast(f32)row_x*t_w_h.x)
    mesh.vertices[4+(18*tile_index)] = 1*t_w_h.y+(cast(f32)col_y*t_w_h.y)
    mesh.vertices[5+(18*tile_index)] = 0
    mesh.normals[3+(18*tile_index)] = 0
    mesh.normals[4+(18*tile_index)] = 0
    mesh.normals[5+(18*tile_index)] = 1

    mesh.texcoords[2+(+12*tile_index)] = t_rec.x/at_w
    mesh.texcoords[3+(+12*tile_index)] = (t_rec.y+t_rec.height)/at_h

    // top_right
    mesh.vertices[6+(18*tile_index)] = 1*t_w_h.x+(cast(f32)row_x*t_w_h.x)
    mesh.vertices[7+(18*tile_index)] = 0*t_w_h.y+(cast(f32)col_y*t_w_h.y)
    mesh.vertices[8+(18*tile_index)] = 0
    mesh.normals[6+(18*tile_index)] = 0
    mesh.normals[7+(18*tile_index)] = 0
    mesh.normals[8+(18*tile_index)] = 1

    mesh.texcoords[4+(+12*tile_index)] = (t_rec.x+t_rec.width)/at_w
    mesh.texcoords[5+(+12*tile_index)] = t_rec.y/at_h


    //try 2 -----------------------------------------
        // bot_right
    mesh.vertices[0+9+(18*tile_index)] = 1*t_w_h.x+(cast(f32)row_x*t_w_h.x)
    mesh.vertices[1+9+(18*tile_index)] = 1*t_w_h.y+(cast(f32)col_y*t_w_h.y)
    mesh.vertices[2+9+(18*tile_index)] = 0
    mesh.normals[0+9+(18*tile_index)] = 0
    mesh.normals[1+9+(18*tile_index)] = 0
    mesh.normals[2+9+(18*tile_index)] = 1

    mesh.texcoords[0+6+(+12*tile_index)] = (t_rec.x+t_rec.width)/at_w
    mesh.texcoords[1+6+(+12*tile_index)] = (t_rec.y+t_rec.height)/at_h

    // top_right
    mesh.vertices[3+9+(18*tile_index)] = 1*t_w_h.x+(cast(f32)row_x*t_w_h.x)
    mesh.vertices[4+9+(18*tile_index)] = 0*t_w_h.y+(cast(f32)col_y*t_w_h.y)
    mesh.vertices[5+9+(18*tile_index)] = 0
    mesh.normals[3+9+(18*tile_index)] = 0
    mesh.normals[4+9+(18*tile_index)] = 0
    mesh.normals[5+9+(18*tile_index)] = 1

    mesh.texcoords[2+6+(+12*tile_index)] = (t_rec.x+t_rec.width)/at_w
    mesh.texcoords[3+6+(+12*tile_index)] = t_rec.y/at_h

    // bot_left
    mesh.vertices[6+9+(18*tile_index)] = 0*t_w_h.x+(cast(f32)row_x*t_w_h.x)
    mesh.vertices[7+9+(18*tile_index)] = 1*t_w_h.y+(cast(f32)col_y*t_w_h.y)
    mesh.vertices[8+9+(18*tile_index)] = 0
    mesh.normals[6+9+(18*tile_index)] = 0
    mesh.normals[7+9+(18*tile_index)] = 0
    mesh.normals[8+9+(18*tile_index)] = 1

    mesh.texcoords[4+6+(+12*tile_index)] = t_rec.x/at_w
    mesh.texcoords[5+6+(+12*tile_index)] = (t_rec.y+t_rec.height)/at_h
}
