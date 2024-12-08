#version 120

attribute vec3 mc_Entity;

varying vec2 texcoord;
varying vec2 lmcoord;
varying vec2 LightmapCoords;
varying vec3 Normal;
varying vec4 Color;
varying float blockId;

void main() {
    // Transform the vertex
    gl_Position = ftransform();
    // Assign values to varying variables
    texcoord = gl_MultiTexCoord0.st;
    lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
    // Use the texture matrix instead of dividing by 15 to maintain compatiblity for each version of Minecraft
    LightmapCoords = mat2(gl_TextureMatrix[1]) * gl_MultiTexCoord1.st;
    // Transform them into the [0, 1] range
    LightmapCoords = (LightmapCoords * 33.05f / 32.0f) - (1.05f / 32.0f);
    Normal = gl_NormalMatrix * gl_Normal;
    Color = gl_Color;
    blockId = mc_Entity.x;
}