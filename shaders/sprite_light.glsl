uniform Image nm;
uniform Image depth;
uniform Image ao;
uniform Image spec;
uniform vec3 light_pos;
//These are used for getting the pixel positions.
uniform int res_x; //This should be the resolution of the image
uniform int res_y;
uniform int offset_x;
uniform int offset_y;

struct Light {
    vec3 light_pos;
    vec3 light_color;
};

// credits to ashleyjamesy for teaching me how to do this
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
    //texnormal.y = texnormal.y; //We also need to flip the y axis, because love treats top-left of screen as (0,0), but glsl treats bottom left.
    texnormal.xyz = (texnormal.xyz - 0.5) * 2;

    //The texture vector (aka the xyz position of a pixel)
    vec3 tex_pos = vec3(pixel_coords.xy, (texdepth) * 100); //We used the normal map's alpha channel for z offset.

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
        float attenuation = 60000/pow(dist, 2) * Texel(spec, texture_coords).x;
        vec3 light_col = lights[i].light_color;

        /*
            Height map based self shadow:
            First, we take a line from the testing point towards the light.
            We linearly interpolate this line and for each point,
            compare the interpolated z value and the z value from the height map at the same point.
            If the height map has a higher z value, then the point should be in shadow.
            Otherwise, the point is in lights.
        */
        vec2 vector_to_light = light_pos.xy - tex_pos.xy;
        vec3 working_point = tex_pos; //This is the point that we need to check whether its in shadow or not.
        float work_steps = length(tex_pos.xy - light_pos.xy); //The distance is basically how many points we are checking.
        float doLighting = 1.0;
        for(float i = 1; i <= work_steps; i++){
            //Linearly interpolate the point towards the light.
            vec3 height_check_point = (light_pos - working_point) * (i / work_steps) + working_point;

            //Using the offset, we can get a uv map that's dedicated specifically to the sprite we are drawing.
            vec2 checkpoint_uv = vec2(floor(height_check_point.x + 0.5 - offset_x) / res_x, floor(height_check_point.y + 0.5 - offset_y) / res_y);
            //With this uv, we can get the depth map at the point we want to compare
            vec4 height_at_point = Texel(depth, checkpoint_uv) * 100;
            if(height_at_point.w == 0){
                break; //We are out of the object bounds. No need to continue checking.
            }
            if(height_check_point.z < height_at_point.x){ //If the point's z value is lower than the z value given from the depth map,
                //Then the point is in shadows. We no longer need to do the rest checking. Just break out of the loop.
                float z_difference = height_at_point.x - height_check_point.z;
                doLighting = clamp(1/(z_difference * 2), 0, 1);
                break;
            }
        }
        resColor.xyz += texcolor.xyz * lightness * light_col * attenuation * doLighting;
    }
    //A bit of ambient light. This ambient light is then multiplied by the ambient occlusion mapping's color.
    vec3 ambient = vec3(0.1, 0.05, 0.15);// * min(texnormal.x, 0);
    ambient.xyz *= Texel(ao, texture_coords).x;
    //What we are returning:
    //The base color of the texture * the lightness of the sun * sunlight color + ambient color as the rgb channel,
    //The alpha channel of the texture
    //Times the color which is set by love.graphics.setColor()
    return vec4((resColor + ambient.xyz),texcolor.w) * color;
}