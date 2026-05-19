// https://github.com/Mrwang2408/RCN-shaders/
// by Mrwang2408
// <RCN_apply.h>

void chunk_border(inout vec4 diffuse, highp vec3 chunkPos)
{
    highp vec3 cp = fract(chunkPos.xyz);

    if (((chunkPos.x < 0.0625 || chunkPos.x > 15.9375) && (chunkPos.y < 0.0625 || chunkPos.y > 15.9375)) ||
        ((chunkPos.x < 0.0625 || chunkPos.x > 15.9375) && (chunkPos.z < 0.0625 || chunkPos.z > 15.9375)) ||
        ((chunkPos.y < 0.0625 || chunkPos.y > 15.9375) && (chunkPos.z < 0.0625 || chunkPos.z > 15.9375)))
    {
        diffuse.rgb = mix(diffuse.rgb, vec3(0.0, 0.0, 1.0), 0.2);
    }
    else if (((chunkPos.x < 0.09375 || chunkPos.x > 15.90625) || (chunkPos.z < 0.09375 || chunkPos.z > 15.90625)) &&
             (((cp.x < 0.03125 || cp.x > 0.96875) && (cp.y < 0.03125 || cp.y > 0.96875)) ||
              ((cp.x < 0.03125 || cp.x > 0.96875) && (cp.z < 0.03125 || cp.z > 0.96875)) ||
              ((cp.y < 0.03125 || cp.y > 0.96875) && (cp.z < 0.03125 || cp.z > 0.96875))))
    {
        diffuse.rgb = (diffuse.rgb / 0.4) * (vec3(1.0, 1.0, 1.0) - diffuse.rgb);
    }
}

bool get_digit_shape(int d, vec3 p)
{
    bool xL = (p.x >= 0.25 && p.x <= 0.35);
    bool xM = (p.x >= 0.35 && p.x <= 0.45);
    bool xR = (p.x >= 0.45 && p.x <= 0.55);

    bool zB = (p.z >= 0.25 && p.z <= 0.35); // Bottom
    bool zC = (p.z >= 0.45 && p.z <= 0.55); // Center
    bool zT = (p.z >= 0.65 && p.z <= 0.75); // Top
    
    bool xLR = (p.x >= 0.25 && p.x <= 0.55);
    bool xLM = (p.x >= 0.25 && p.x <= 0.45);
    bool xMR = (p.x >= 0.35 && p.x <= 0.55);
    bool zBT = (p.z >= 0.25 && p.z <= 0.75); 

    if (d == 0) return (xL && zBT) || (xR && zBT) || (xM && zT) || (xM && zB);

    if (d == 1) return (xLR && zB) || (xM && p.z >= 0.35 && p.z <= 0.75) || (xR && zT);

    if (d == 2) return (xM && zC) || (xL && p.z >= 0.45 && p.z <= 0.75) || (xR && p.z >= 0.25 && p.z <= 0.55) || (xLM && zB) || (xMR && zT);

    if (d == 3) return (xL && zBT) || (xMR && zC) || (xMR && zB) || (xMR && zT);

    if (d == 4) return (xL && zBT) || (xR && p.z >= 0.45 && p.z <= 0.75) || (xM && zC);

    if (d == 5) return (xM && zC) || (xL && p.z >= 0.25 && p.z <= 0.55) || (xR && p.z >= 0.45 && p.z <= 0.75) || (xLM && zT) || (xMR && zB);

    if (d == 6) return (xM && zC) || (xL && p.z >= 0.25 && p.z <= 0.55) || (xR && p.z >= 0.35 && p.z <= 0.75) || (xLM && zT) || (xMR && zB);

    if (d == 7) return (xL && zBT) || (xMR && zT) || (xR && p.z >= 0.60 && p.z <= 0.65);

    if (d == 8) return (xM && zC) || (xL && zBT) || (xR && zBT) || (xM && zT) || (xM && zB);

    if (d == 9) return (xM && zC) || (xL && p.z >= 0.35 && p.z <= 0.75) || (xR && p.z >= 0.45 && p.z <= 0.75) || (xLR && zB) || (xMR && zT);

    return false;
}

bool get_number_match(int L, vec3 bp)
{
    if (L < 0) return false;
    if (L <= 9) return get_digit_shape(L, bp);

    bool tens = (bp.x <= 0.7 && bp.x >= 0.4 && bp.z <= 0.35 && bp.z >= 0.25)
             || (bp.x <= 0.6 && bp.x >= 0.5 && bp.z <= 0.75 && bp.z >= 0.35)
             || (bp.x <= 0.7 && bp.x >= 0.6 && bp.z <= 0.75 && bp.z >= 0.65);

    return tens || get_digit_shape(L - 10, bp + vec3(0.15, 0.0, 0.0));
}

void red_stone_level(inout bool needDiscard, inout bool isRedstoneDust, inout vec4 diffuse, vec3 cp, vec3 color)
{
    if (color.r <= color.g + color.b) return;

    int L = -1;
    if      (color.r > 0.999 && color.g > 0.191 && color.g < 0.201 && color.b < 0.005) L = 15;
    else if (color.r > 0.952 && color.r < 0.962 && color.g > 0.101 && color.g < 0.111 && color.b < 0.005) L = 14;
    else if (color.r > 0.913 && color.r < 0.923 && color.g > 0.019 && color.g < 0.029 && color.b < 0.005) L = 13;
    else if (color.r > 0.873 && color.r < 0.883 && color.g + color.b < 0.005) L = 12;
    else if (color.r > 0.834 && color.r < 0.844 && color.g + color.b < 0.005) L = 11;
    else if (color.r > 0.795 && color.r < 0.805 && color.g + color.b < 0.005) L = 10;
    else if (color.r > 0.752 && color.r < 0.762 && color.g + color.b < 0.005) L = 9;
    else if (color.r > 0.713 && color.r < 0.723 && color.g + color.b < 0.005) L = 8;
    else if (color.r > 0.673 && color.r < 0.683 && color.g + color.b < 0.005) L = 7;
    else if (color.r > 0.634 && color.r < 0.644 && color.g + color.b < 0.005) L = 6;
    else if (color.r > 0.595 && color.r < 0.605 && color.g + color.b < 0.005) L = 5;
    else if (color.r > 0.552 && color.r < 0.562 && color.g + color.b < 0.005) L = 4;
    else if (color.r > 0.513 && color.r < 0.523 && color.g + color.b < 0.005) L = 3;
    else if (color.r > 0.473 && color.r < 0.483 && color.g + color.b < 0.005) L = 2;
    else if (color.r > 0.434 && color.r < 0.444 && color.g + color.b < 0.005) L = 1;
    else if (color.r > 0.293 && color.r < 0.303 && color.g + color.b < 0.005) L = 0;

    if (L < 0) return;

    isRedstoneDust = true;
    bool match = (cp.x <= 0.7 && cp.x >= 0.1 && cp.z <= 0.08 && cp.z >= 0.05)
              || (cp.x <= 0.7 && cp.x >= 0.1 && cp.z <= 0.20 && cp.z >= 0.17)
              || (mod(floor(float(L) / exp2(floor(6.667 * (cp.x - 0.1)))), 2.0) >= 0.5 && cp.z <= 0.15 && cp.z >= 0.1);

    if (match || get_number_match(L, cp))
    {
        diffuse = vec4(1.0, 1.0, 1.0, 1.0);
        needDiscard = false;
    }
}

void light_overlay(inout bool needDiscard, inout int isLightOverlay, vec3 cp, vec2 v_lightmapUV)
{
    ivec2 lightLevel = ivec2(v_lightmapUV * 16.0 + 0.001);
    vec3 bp = cp;
    bp.x -= 0.13;

    int L = lightLevel.x;
    for (int i = 0; i < 2; i++)
    {
        int colorType;
        if (i == 0) colorType = (L == 0) ? 2 : 1;
        else        colorType = (L <= 7) ? 3 : 1;

        if (get_number_match(L, bp))
        {
            isLightOverlay = colorType;
            #ifdef ALPHA_TEST_PASS
            needDiscard = false;
            #endif
        }

        if (i == 0)
        {
            bp.x = bp.x * 2.0 + 0.55;
            bp.z = bp.z * 2.0 - 0.25;
            L = lightLevel.y;
        }
    }

    if (v_lightmapUV.x + 0.001 > 0.0615 && v_lightmapUV.x + 0.001 < 0.0625)
    {
        isLightOverlay = 5;
    }
    else if (v_lightmapUV.y + 0.001 > 0.4995 && v_lightmapUV.y + 0.001 < 0.5005)
    {
        isLightOverlay = 4;
    }
}