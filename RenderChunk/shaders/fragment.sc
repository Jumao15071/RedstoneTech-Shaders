$input v_color0, v_texcoord0, v_lightmapUV, v_position, v_worldpos, v_fog

#include <bgfx_shader.sh>
#include <defines.sh>
#include <RCN_config.h>
#include <RCN_apply.h>

SAMPLER2D(s_LightMapTexture, 0);
SAMPLER2D(s_MatTexture,      1);
SAMPLER2D(s_SeasonsTexture,  2);

void main() {
    vec4 diffuse;
    bool needDiscard = false;
    bool isRedstoneDust = false;
    bool needLightMap = true; 
    int isLightOverlay = 0;
    vec3 chunkPos = v_position; 
    vec3 cp = fract(v_position);

    diffuse = texture2D(s_MatTexture, v_texcoord0);

    #if defined(ALPHA_TEST) || defined(ALPHA_TEST_PASS)
        if (diffuse.a < 0.5) {
            needDiscard = true; 
        }
    #endif

    #if defined(SEASONS__ON) && (defined(OPAQUE_PASS) || defined(ALPHA_TEST_PASS))
        diffuse.rgb *= mix(vec3(1.0, 1.0, 1.0), texture2D(s_SeasonsTexture, v_color0.xy).rgb * 2.0, v_color0.b);
        diffuse.rgb *= v_color0.aaa;
    #else
        diffuse *= v_color0;
    #endif

    #if defined(REDSTONE_OVERLAY) || defined(LIGHT_OVERLAY) || defined(CHUNK_BORDERS)
        vec3 normal = normalize(cross(dFdx(v_position), dFdy(v_position)));
        
        #if defined(REDSTONE_OVERLAY) || defined(LIGHT_OVERLAY)
            if (normal.y > 0.99) {
                cp.x = cp.x * 3.0 - 1.1;
                cp.z = cp.z * 3.0 - 1.1;
                
                #ifdef REDSTONE_OVERLAY
                    red_stone_level(needDiscard, isRedstoneDust, diffuse, cp, v_color0.rgb);
                #endif

                #ifdef LIGHT_OVERLAY
                    if (!isRedstoneDust && length(v_worldpos.xyz) < 64.0) {
                        light_overlay(needDiscard, isLightOverlay, cp, v_lightmapUV);
                    }
                #endif
            }
        #endif
    #endif

    #ifdef ORE_TEST
        vec4 oreTest = texture2DLod(s_MatTexture, v_texcoord0, 0.0);
        if (oreTest.a > 0.988 && oreTest.a < 0.993) {
            vec3 glow = oreTest.rgb * oreTest.rgb;
            if (oreTest.a > 0.989) {
                glow *= 0.4;
            }
            needLightMap = false;
            diffuse.rgb *= (2.0 - v_color0.rgb);
            diffuse.rgb += glow * 0.5;
            diffuse.rgb *= 0.4 + 0.625 * texture2DLod(s_LightMapTexture, v_lightmapUV, 0.0).rgb;
        }
    #endif


    #if defined(ALPHA_TEST) || defined(ALPHA_TEST_PASS)
        if (needDiscard) {
            discard;
        }
    #endif

    #if !defined(NIGHT_VISION)
        if (needLightMap) {
            diffuse.rgb *= texture2D(s_LightMapTexture, v_lightmapUV).rgb;
        }
    #endif

    #ifdef LIGHT_OVERLAY
        if(isLightOverlay == 1) {
            diffuse.rgb = mix(diffuse.rgb, vec3(0.0, 1.0, 0.0), 0.3);
        } else if(isLightOverlay == 2) {
            diffuse.rgb = mix(diffuse.rgb, vec3(1.0, 0.0, 0.0), 0.15);
        } else if(isLightOverlay == 3) {
            diffuse.rgb = mix(diffuse.rgb, vec3(0.1, 0.1, 1.0), 0.2);
        } else if(isLightOverlay == 4) {
            diffuse.rgb = mix(diffuse.rgb, vec3(0.0, 0.5, 1.0), 0.4);
        } else if(isLightOverlay == 5) {
            diffuse.rgb = mix(diffuse.rgb, vec3(0.85, 0.64, 0.07), 0.4);
        }
    #endif

    #ifdef CHUNK_BORDERS
        chunk_border(diffuse, chunkPos);
    #endif

    diffuse.rgb = mix(diffuse.rgb, v_fog.rgb, v_fog.a);
    gl_FragColor = diffuse;
}