
vec2 screen_res = vec2(512.0, 512.0);
vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords){
    //vec2 expandedCoords = texture_coords.xy * screen_res.xy;
    return vec4(pixel_coords.x / screen_res.x, pixel_coords.y / screen_res.y, 0, 1);
}

