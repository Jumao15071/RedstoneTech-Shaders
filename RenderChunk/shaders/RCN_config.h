//这一坨是为了减小编译后的体积
// 0: 有夜视 + 有亮度
// 1: 有夜视 + 无亮度
// 2: 无夜视 + 有亮度
// 3: 无夜视 + 无亮度
#define SUBPACKS 0
#if SUBPACKS == 0 || SUBPACKS == 1
    #define NIGHT_VISION
#endif

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

#if SUBPACKS == 1 || SUBPACKS == 3
    #ifdef LIGHT_OVERLAY
        #undef LIGHT_OVERLAY
    #endif
#endif