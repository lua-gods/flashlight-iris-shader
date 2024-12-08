#version 120

varying vec2 texcoord;
varying vec2 lmcoord;
varying vec2 LightmapCoords;
varying vec3 Normal;
varying vec4 Color;

uniform sampler2D lightmap;
uniform sampler2D texture;

varying float blockId;

void main(){
    vec4 color = texture2D(texture, texcoord) * Color;
    int id = int(blockId + 0.5);
    if (id == 21) {
        color *= vec4(0.9, 0.8, 0.85, 1.0);
    }
    float sunLight = dot(texture2D(lightmap, lmcoord).rgb, vec3(0.30, 0.59, 0.11));
    /* DRAWBUFFERS:012 */
    gl_FragData[0] = color;
    gl_FragData[1] = vec4(Normal * 0.5f + 0.5f, 1.0f);
    gl_FragData[2] = vec4(LightmapCoords, sunLight, 1.0f);
}