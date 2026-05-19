$input a_color0, a_position, a_texcoord0, a_texcoord1

#ifdef INSTANCING
    $input i_data0, i_data1, i_data2, i_data3
#endif

$output v_color0, v_texcoord0, v_lightmapUV, v_position, v_worldpos, v_fog

#include <bgfx_shader.sh>
#include <defines.sh>
#include <RCN_config.h>

uniform vec4 RenderChunkFogAlpha;
uniform vec4 FogAndDistanceControl;
uniform vec4 ViewPositionAndTime;
uniform vec4 FogColor;

void main(){
    mat4 model;
    #ifdef INSTANCING
        model = mtxFromCols(i_data0, i_data1, i_data2, i_data3);
    #else
        model = u_model[0];
    #endif

    vec3 worldPos = mul(model, vec4(a_position, 1.0)).xyz;
    vec4 color = a_color0;
    v_position = a_position;

    #ifdef RENDER_AS_BILLBOARDS
        vec3 worldPosBefore = worldPos;
        worldPos += 0.5;
        vec3 viewDir = normalize(worldPos - ViewPositionAndTime.xyz);
        vec3 boardPlane = normalize(vec3(viewDir.z, 0.0, -viewDir.x));
        worldPos = (worldPos - ((((viewDir.yzx * boardPlane.zxy) - (viewDir.zxy * boardPlane.yzx)) * (a_color0.z - 0.5)) + (boardPlane * (a_color0.x - 0.5))));
        color = vec4(1.0, 1.0, 1.0, 1.0);
        v_position += worldPos - worldPosBefore;
    #endif

    #ifdef CHUNK_ANIM
        worldPos.y -= CHUNK_ANIM * pow(RenderChunkFogAlpha.x, 3.0);
    #endif

    v_texcoord0 = a_texcoord0;
    float packedValue = a_texcoord1.y * 65535.0;
    uint intValue = uint(floor(packedValue));
    float lightmapU = float(intValue >> 4u);
    float lightmapV = float(intValue & 15u);
    v_lightmapUV = clamp(vec2(lightmapU, lightmapV) * 0.0625, 0.0, 1.0);
    v_color0 = color;
    v_worldpos = worldPos;

    vec3 modelCamPos = (ViewPositionAndTime.xyz - worldPos);
    float camDis = length(modelCamPos);

    #ifndef NO_FOG
        vec4 fogColor;
        fogColor.rgb = FogColor.rgb;
        float fogAlpha = clamp(((((camDis / FogAndDistanceControl.z) + RenderChunkFogAlpha.x) - FogAndDistanceControl.x) / (FogAndDistanceControl.y - FogAndDistanceControl.x)), 0.0, 1.0);
        fogColor.a = RenderChunkFogAlpha.x;
        v_fog = fogColor;
    #endif

    gl_Position = mul(u_viewProj, vec4(worldPos, 1.0));
}