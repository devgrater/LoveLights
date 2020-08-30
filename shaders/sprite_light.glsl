uniform Image nm;
uniform Image depth;
uniform Image ao;
uniform Image spec;
uniform vec3 light_pos;
//These are used for getting the pixel positions.
uniform int res_x;
uniform int res_y;

struct Light {
    vec3 light_pos;
    vec3 light_color;
};
const int MAX_LIGHTS = 8; // Max 8 lights
//const int MAX_RAY_STEPS = 15;
uniform Light lights[MAX_LIGHTS];
uniform int light_count = 0;


//Lots of things to explain here!
//For understanding how things work, I would recommend replacing the textures with the shelf_normal_flat to test with.
//This should give you more idea of what component is doing what.
vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)//This is the default function header(?) you need to use for it to work with love.
{
    vec4 texcolor = Texel(texture, texture_coords).xyzw; //This is the color for the texture we just draw, aka the bookshelf.
    vec3 texnormal = Texel(nm, texture_coords).xyz; //The normal is passed in before the draw call, if you might recall.
    float texdepth = Texel(depth, texture_coords).x;

    //The normal is stored in a color map that has range of 0 to 1, but we need to convert the normal
    //such that it becomes a range of -1 to 1.
    texnormal.y = 1 - texnormal.y; //We also need to flip the y axis, because love treats top-left of screen as (0,0), but glsl treats bottom left.
    texnormal.xyz = (texnormal.xyz - 0.5) * 2;

    //The texture vector (aka the xyz position of a pixel)
    vec3 tex_pos = vec3(pixel_coords.xy, (texdepth - 1) * 8); //We used the normal map's alpha channel for z offset.

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

        //Check if we need to cast shadows on self - this sounds difficult.
        //First, lets calculate out the diagonal distance. This would be the max distance of changes on the x and y axis.
        float dx = abs(light_pos.x - tex_pos.x);
        float dy = abs(light_pos.y - tex_pos.y);
        //float dz = abs(light_pos.z - tex_pos.z);
        float diag_dist = max(dx, dy);//Takes the max distance as the number of steps to perform
        float shadowValue = 1.0f;
        for(float j = 1; j <= diag_dist; j++){
            //Use this as a percentage to calculate out the points.
            //Alright, first calculate out the positions.
            float percentage = j / diag_dist;
            //This gives me something that resembles a ray.
            vec3 pixel_pos = (light_pos - tex_pos) * percentage + tex_pos;

            vec2 tex_uv_pos = vec2(pixel_pos.x / res_x, pixel_pos.y / res_y);
            float pixel_depth = (Texel(depth, tex_uv_pos).x - 1) * 8;

            if(Texel(texture, tex_uv_pos).w <= 0){
                break;
            }
            //Now we can shade the thing using these information.
            if(tex_pos.z < pixel_depth){//This should give us the ability to tell whether something is blocked by light...

                shadowValue = (1 - (pixel_depth - pixel_pos.z)) / 16.0f;
                //shadowValue = 0.0f;
                break;
            }
        }

        resColor.xyz += texcolor.xyz * lightness * light_col * attenuation * shadowValue;
    }
    //A bit of ambient light. This ambient light is then multiplied by the ambient occlusion mapping's color.
    vec3 ambient = vec3(0.1, 0.05, 0.15);
    ambient.xyz *= Texel(ao, texture_coords).x;
    //What we are returning:
    //The base color of the texture * the lightness of the sun * sunlight color + ambient color as the rgb channel,
    //The alpha channel of the texture
    //Times the color which is set by love.graphics.setColor()
    return vec4((resColor + ambient.xyz),texcolor.w) * color;
}