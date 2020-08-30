uniform Image nm;
uniform Image ao;
uniform Image spec;
uniform vec3 light_pos;

struct Light {
    vec3 light_pos;
    vec3 light_color;
};
const int MAX_LIGHTS = 8; // Max 8 lights
uniform Light lights[MAX_LIGHTS];
uniform int light_count = 0;


//Lots of things to explain here!
//For understanding how things work, I would recommend replacing the textures with the shelf_normal_flat to test with.
//This should give you more idea of what component is doing what.
vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)//This is the default function header(?) you need to use for it to work with love.
{
    vec4 texcolor = Texel(texture, texture_coords).xyzw; //This is the color for the texture we just draw, aka the bookshelf.
    vec4 texnormal = Texel(nm, texture_coords).xyzw; //The normal is passed in before the draw call, if you might recall.

    //The normal is stored in a color map that has range of 0 to 1, but we need to convert the normal
    //such that it becomes a range of -1 to 1.
    texnormal.y = 1 - texnormal.y; //We also need to flip the y axis, because love treats top-left of screen as (0,0), but glsl treats bottom left.
    texnormal.xyz = (texnormal.xyz - 0.5) * 2;

    //The texture vector (aka the xyz position of a pixel)
    vec3 tex_pos = vec3(pixel_coords.xy, (texnormal.w - 1) * 16); //We used the normal map's alpha channel for z offset.

    vec3 resColor = vec3(0.0, 0.0, 0.0);
    for(int i = 0; i < light_count; i++){
        //Do something with the lights and calculate out the rest.
        //First we know the position of the light
        vec3 light_pos = lights[i].light_pos;
        //Then we know the position of the pixel. By doing a bit of subtraction, we get a vector that points from light to the pixel.
        vec3 light_vec = normalize(light_pos - tex_pos);
        //The dot product between this light and the normal is how bright the pixel will be.
        float lightness = clamp(dot(light_vec, texnormal.xyz), 0, 1);

        float dist = length(tex_pos - light_pos);
        float attenuation = 700/pow(dist, 2) * Texel(spec, texture_coords).x;
        vec3 light_col = lights[i].light_color;

        resColor.xyz += texcolor.xyz * lightness * light_col * attenuation;
    }
    //A bit of ambient light. This ambient light is then multiplied by the ambient occlusion mapping's color.
    vec3 ambient = vec3(0.1, 0.05, 0.15);
    ambient.xyz *= Texel(ao, texture_coords).xxx;
    //What we are returning:
    //The base color of the texture * the lightness of the sun * sunlight color + ambient color as the rgb channel,
    //The alpha channel of the texture
    //Times the color which is set by love.graphics.setColor()
    return vec4((resColor + ambient.xyz),texcolor.w) * color;
}