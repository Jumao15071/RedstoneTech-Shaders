//这一坨是为了减小编译后的体积
#if !defined(DEPTH_ONLY) && !defined(DEPTH_ONLY_OPAQUE)
    #if !defined(INSTANCING) && !defined(INSTANCING__ON) && !defined(RENDER_AS_BILLBOARDS)
        
        #if defined(SEASONS) || defined(SEASONS__ON)
            #if defined(ALPHA_TEST) || defined(ALPHA_TEST_PASS)
                #define CHUNK_BORDERS 
                #define LIGHT_OVERLAY 
            #endif
        #else 
            #if defined(ALPHA_TEST) || defined(ALPHA_TEST_PASS)
                #if !defined(TRANSPARENT) && !defined(TRANSPARENT_PASS)
                    #define REDSTONE_OVERLAY
                #endif
                #define ORE_TEST 
                #define CHUNK_BORDERS 
                #define LIGHT_OVERLAY
            #endif
            #if defined(OPAQUE) || defined(OPAQUE_PASS)
                #define ORE_TEST 
                #define CHUNK_BORDERS 
                #define LIGHT_OVERLAY 
            #endif
            #if defined(TRANSPARENT) || defined(TRANSPARENT_PASS)
                #define CHUNK_BORDERS 
            #endif
        #endif
    #endif 
#endif

// 0: 有夜视 + 有亮度 + 有区块显示
// 1: 有夜视 + 无亮度 + 有区块显示
// 2: 无夜视 + 有亮度 + 有区块显示
// 3: 无夜视 + 无亮度 + 有区块显示
// 4: 有夜视 + 有亮度 + 无区块显示
// 5: 有夜视 + 无亮度 + 无区块显示
// 6: 无夜视 + 有亮度 + 无区块显示
// 7: 无夜视 + 无亮度 + 无区块显示
#define SUBPACKS 0

#if SUBPACKS == 0 || SUBPACKS == 1 || SUBPACKS == 4 || SUBPACKS == 5
    #define NIGHT_VISION
#endif
#if SUBPACKS == 1 || SUBPACKS == 3 || SUBPACKS == 5 || SUBPACKS == 7
    #ifdef LIGHT_OVERLAY
        #undef LIGHT_OVERLAY
    #endif
#endif
#if SUBPACKS == 4 || SUBPACKS == 5 || SUBPACKS == 6 || SUBPACKS == 7
    #ifdef CHUNK_BORDERS
        #undef CHUNK_BORDERS
    #endif
#endif