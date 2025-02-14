#version 120

varying vec2 texcoord;

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D depthtex1;

uniform float aspectRatio;
uniform float near;
uniform float far;
uniform float frameTimeCounter;

float linearizeDepthFast(float depth) {
   return (near * far) / (depth * (near - far) + far);
}

float rand(float n) {
    return fract(sin(n) * 43758.5453123);
}

void main(){
    // get color
    vec3 color = texture2D(colortex0, texcoord).rgb;
    float depth = texture2D(depthtex1, texcoord).r;
    if(depth == 1.0f){
        gl_FragData[0] = vec4(color, 1.0f);
        // return;
    }
    // linearize depth
    depth = linearizeDepthFast(depth);
    // get normal
    vec3 normal = texture2D(colortex1, texcoord).rgb * 2.0 - 1.0;
    // get lightmap
    vec3 lightmap = texture2D(colortex2, texcoord).rgb;
    // flashlight
    float flashlightDepth = min(depth, 15.0);
    float dist = length((texcoord - 0.5) * vec2(max(aspectRatio, 1.0), max(1.0 / aspectRatio, 1.0)));
    float flashlight = clamp(
        (1-(dist / (0.4 + flashlightDepth * 0.02)) * 10.0 + 5.0)
        , 0.0, 1.0
    );
    flashlight = -(cos(flashlight * 3.1415) - 1.0) * 0.5;
    flashlight = clamp(flashlight +(0.4-(dist / (1 + flashlightDepth * 0.02)) * 3.0 + 0.9) * 0.7 , 0.0, 1.0);
    flashlight = clamp(flashlight +(0.4-(dist / (1 + flashlightDepth * 0.02)) * 1.0 + 0.8) * 0.1 , 0.0, 1.0);
    flashlight *= clamp(1.0 - flashlightDepth * 0.05, 0.0, 1.0);
    flashlight *= sqrt(max(normal.z, 0.0)) * 0.5 + 0.5;
    flashlight *= 2.0;
    // random flickering
    if (abs(rand(floor(frameTimeCounter + 1.0)) * 4.0 - fract(frameTimeCounter)) < 0.25) {
        if (cos(frameTimeCounter * 16.0) > 0.0) {
            flashlight = 0.0;
        }
    }
    // apply light
    // float vanillaLight = max(lightmap.x, lightmap.y * lightmap.z);
    float vanillaLight = lightmap.x;
    vanillaLight *= vanillaLight;
    vanillaLight *= vanillaLight;
    vanillaLight *= vanillaLight;
    vanillaLight = min(vanillaLight * 1.5, 1.0);
    color *= max(vanillaLight, flashlight);
    // fog
    float fogDist = depth + dist * 2.0 - vanillaLight * 5.0;
    float fogStrength = (fogDist - 2.0) * 0.15;
    fogStrength = log(fogStrength * 20.0) * 0.3;
    fogStrength = clamp(fogStrength, 0.0, 1.0);
    color = mix(color, vec3(0.15, 0.12, 0.1) + flashlight * 0.02, fogStrength);
    /* DRAWBUFFERS:0 */
    gl_FragData[0] = vec4(color, 1.0f);
}