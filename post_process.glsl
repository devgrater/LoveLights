
vec2 screen_res = vec2(64.0, 64.0);
mat3x3 kernel = mat3x3(
    1,2,1,
    2,4,2,
    1,2,1
);
float mult = 1.0f/16.0f;

vec4 getColorAt(Image texture, vec2 expandedCoords){
    //vec2 normalizedCoords = clamp(expandedCoords, 0, screen_res) / screen_res; //Thsi gives a normalized screen coordinates.
    vec2 normalizedCoords = vec2(
        clamp(expandedCoords.x, 0, screen_res.x),
        clamp(expandedCoords.y, 0, screen_res.y)
    );
    normalizedCoords.xy /= screen_res.xy;
    return Texel(texture, normalizedCoords).xyzw;
}
//                                                              v This thing right here is not normalized.
//Simple gaussian kernel
vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords){
    //vec2 expandedCoords = texture_coords.xy * screen_res.xy;
    vec4 sumColor = vec4(0, 0, 0, 0);
    for(int x = -1; x <= 1; x++){
        for(int y = -1; y <= 1; y++){
            vec2 tempCoords = (texture_coords.xy * screen_res.xy + vec2(x,y));
            sumColor += getColorAt(texture, tempCoords) * kernel[x+1][y+1];
            //sumColor += vec2(x,y);
        }
    }
    return sumColor.wwww * 1.5 * mult * color;
}

