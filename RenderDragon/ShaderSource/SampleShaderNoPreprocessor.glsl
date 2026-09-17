// https://raw.githubusercontent.com/KhronosGroup/glslang/d9b08d5c3db62317c98a135e1c2cc616f1bafc61/Test/specExamples.frag

#version 430

#extension GL_3DL_array_objects : enable

int  a = 0xffffffff;  // 32 bits, a gets the value -1
int  b = 0xffffffffU; // ERROR: can't convert uint to int
uint c = 0xffffffff;  // 32 bits, c gets the value 0xFFFFFFFF
uint d = 0xffffffffU; // 32 bits, d gets the value 0xFFFFFFFF
int  e = -1;          // the literal is "1", then negation is performed,
                      //   and the resulting non-literal 32-bit signed 
                      //   bit pattern of 0xFFFFFFFF is assigned, giving e 
                      //   the value of -1.
uint f = -1u;         // the literal is "1u", then negation is performed,
                      //   and the resulting non-literal 32-bit unsigned 
                      //   bit pattern of 0xFFFFFFFF is assigned, giving f 
                      //   the value of 0xFFFFFFFF.
int  g = 3000000000;  // a signed decimal literal taking 32 bits,
                      //   setting the sign bit, g gets -1294967296
int  h = 0xA0000000;  // okay, 32-bit signed hexadecimal
int  i = 5000000000;  // ERROR: needs more than 32 bits
int  j = 0xFFFFFFFFF; // ERROR: needs more that 32 bits
int  k = 0x80000000;  // k gets -2147483648 == 0x80000000
int  l = 2147483648;  // l gets -2147483648 (the literal set the sign bit)

float fa, fb = 1.5;     // single-precision floating-point
double fc, fd = 2.0LF;  // double-precision floating-point

vec2 texcoord1, texcoord2;
vec3 position;
vec4 myRGBA;
ivec2 textureLookup;
bvec3 less;

mat2 mat2D;
mat3 optMatrix;
mat4 view, projection;
mat4x4 view;  // an alternate way of declaring a mat4
mat3x2 m;     // a matrix with 3 columns and 2 rows
dmat4 highPrecisionMVP;
dmat2x4 dm;

struct light {
    float intensity;
    vec3 position;
} lightVar;

struct S { float f; };

struct T {
	//S;              // Error: anonymous structures disallowed
	//struct { ... }; // Error: embedded structures disallowed
	S s;            // Okay: nested structures with name are allowed
};

float frequencies[3];	
uniform vec4 lightPosition[4];
light lights[];
const int numLights = 2;
light lights[numLights];

in vec3 normal;
centroid in vec2 TexCoord;
invariant centroid in vec4 Color;
noperspective in float temperature;
flat in vec3 myColor;
noperspective centroid in vec2 myTexCoord;

uniform vec4 lightPosition;
uniform vec3 color = vec3(0.7, 0.7, 0.2);  // value assigned at link time

in Material {
    smooth in vec4 Color1; // legal, input inside in block
    smooth vec4 Color2;    // legal, 'in' inherited from 'in Material'
    vec2 TexCoordA;        // legal, TexCoord is an input
    uniform float Atten;   // illegal, mismatched  storage qualifier

};

in Light {
    vec4 LightPos;
    vec3 LightColor;
};
in ColoredTexture {
    vec4 Color;
    vec2 TexCoord;        
} Materiala;           // instance name
vec3 Color;            // different Color than Material.Color

in vec4 gl_FragCoord;     // redeclaration that changes nothing is allowed

// All the following are allowed redeclaration that change behavior
layout(origin_upper_left) in vec4 gl_FragCoord;
layout(pixel_center_integer) in vec4 gl_FragCoord;
layout(origin_upper_left, pixel_center_integer) in vec4 gl_FragCoord;

layout(early_fragment_tests) in;

// compute shader:
layout (local_size_x = 32, local_size_y = 32) in;
layout (local_size_x = 8) in;

layout(location = 3) out vec4 color;
layout(location = 3, index = 1) out vec4 factor;
layout(location = 2) out vec4 colors[3];

layout (depth_greater) out float gl_FragDepth;

// redeclaration that changes nothing is allowed
out float gl_FragDepth;

// assume it may be modified in any way
layout (depth_any) out float gl_FragDepth;

// assume it may be modified such that its value will only increase
layout (depth_greater) out float gl_FragDepth;

// assume it may be modified such that its value will only decrease
layout (depth_less) out float gl_FragDepth;

// assume it will not be modified
layout (depth_unchanged) out float gl_FragDepth;

in vec4 gl_Color;             // predeclared by the fragment language
flat  in vec4 gl_Color;       // redeclared by user to be flat


float[5] foo(float[5]) 
{
    return float[5](3.4, 4.2, 5.0, 5.2, 1.1);
}

precision highp float;
precision highp int;
precision mediump int;
precision highp float;

void main()
{
    {
		float a[5] = float[5](3.4, 4.2, 5.0, 5.2, 1.1);
	}
	{
		float a[5] = float[](3.4, 4.2, 5.0, 5.2, 1.1);  // same thing
	}
    {
	    vec4 a[3][2];  // size-3 array of size-2 array of vec4
		vec4[2] a1[3];  // size-3 array of size-2 array of vec4
		vec4[3][2] a2;  // size-3 array of size-2 array of vec4
		vec4 b[2] = vec4[2](vec4(0.0), vec4(0.1));
		vec4[3][2] a3 = vec4[3][2](b, b, b);        // constructor
		void foo(vec4[3][2]);  // prototype with unnamed parameter
		vec4 a4[3][2] = {vec4[2](vec4(0.0), vec4(1.0)),   
						 vec4[2](vec4(0.0), vec4(1.0)),   
						 vec4[2](vec4(0.0), vec4(1.0)) };
    }
	{
		float a[5];
		{
			float b[] = a;  // b is explicitly size 5
		}
		{
			float b[5] = a; // means the same thing
		}
		{
			float b[] = float[](1,2,3,4,5);  // also explicitly sizes to 5
		}
		a.length();  // returns 5 
	}
    {
		vec4 a[3][2];
		a.length();     // this is 3
		a[x].length();  // this is 2
    }
	// for an array b containing a member array a:
	b[++x].a.length();    // b is never dereferenced, but �++x� is evaluated

	// for an array s of a shader storage object containing a member array a:
	s[x].a.length();      // s is dereferenced; x needs to be a valid index
	//
	//All of the following declarations result in a compile-time error.
	//float a[2] = { 3.4, 4.2, 5.0 };         // illegal
	//vec2 b = { 1.0, 2.0, 3.0 };             // illegal
	//mat3x3 c = { vec3(0.0), vec3(1.0), vec3(2.0), vec3(3.0) };    // illegal
	//mat2x2 d = { 1.0, 0.0, 0.0, 1.0 };      // illegal, can't flatten nesting
	//struct {
	//	float a;
	//	int   b;
	//} e = { 1.2, 2, 3 };                    // illegal

    struct {
        float a;
        int   b;
    } e = { 1.2, 2 };             // legal, all types match

    struct {
        float a;
        int   b;
    } e = { 1, 3 };               // legal, first initializer is converted

    //All of the following declarations result in a compile-time error.
    //int a = true;                           // illegal
    //vec4 b[2] = { vec4(0.0), 1.0 };         // illegal
    //mat4x2 c = { vec3(0.0), vec3(1.0) };    // illegal

    //struct S1 {
    //    vec4 a;
    //    vec4 b;
    //};

    //struct {
    //    float s;
    //    float t;
    //} d[] = { S1(vec4(0.0), vec4(1.1)) };   // illegal

    {
        float a[] = float[](3.4, 4.2, 5.0, 5.2, 1.1);
        float b[] = { 3.4, 4.2, 5.0, 5.2, 1.1 };
        float c[] = a;                          // c is explicitly size 5
        float d[5] = b;                         // means the same thing
    }
    {
        const vec3 zAxis = vec3 (0.0, 0.0, 1.0);
        const float ceiling = a + b; // a and b not necessarily constants
    }
    {
        in vec4 position;
        in vec3 normal;
        in vec2 texCoord[4];
    }
    {
        lowp float color;
        out mediump vec2 P;
        lowp ivec2 foo(lowp mat3);
        highp mat4 m;
    }

}

#version 430

#extension GL_3DL_array_objects : enable

out Vertex {
    vec4 Position;  // API transform/feedback will use �Vertex.Position�
    vec2 Texture;
} Coords;           // shader will use �Coords.Position�

out Vertex2 {
    vec4 Color;     // API will use �Color�
};

uniform Transform {  // API uses �Transform[2]� to refer to instance 2
    mat4           ModelViewMatrix;
    mat4           ModelViewProjectionMatrix;
    vec4           a[];  // array will get implicitly sized
    float          Deformation;
} transforms[4];

layout(location = 3) in vec4 normal;
layout(location = 6) in vec4 colors[3];
layout(location = 9) in mat4 transforms2[2];

layout(location = 3) struct S {
    vec3 a1;
    mat2 b;
    vec4 c[2];
} s;

layout(triangles, invocations = 6) in;

layout(lines) in;    // legal for Color2, input size is 2, matching Color2

layout(triangle_strip, max_vertices = 60) out;  // order does not matter
layout(max_vertices = 60) out;      // redeclaration okay
layout(triangle_strip) out;         // redeclaration okay
//layout(points) out;                 // error, contradicts triangle_strip
//layout(max_vertices = 30) out;      // error, contradicts 60

layout(stream = 1) out;

layout(stream=1) out;             // default is now stream 1
out vec4 var1;                    // var1 gets default stream (1)
layout(stream=2) out Block1 {     // "Block1" belongs to stream 2
    layout(stream=2) vec4 var2;   // redundant block member stream decl
    layout(stream=3) vec2 var3;   // ILLEGAL (must match block stream)
    vec3 var4;                    // belongs to stream 2
};
layout(stream=0) out;             // default is now stream 0
out vec4 var5;                    // var5 gets default stream (0)
out Block2 {                      // "Block2" gets default stream (0)
    vec4 var6;
};
layout(stream=3) out vec4 var7;   // var7 belongs to stream 3

layout(shared, column_major) uniform;
layout(shared, column_major) buffer;

layout(row_major, column_major);

layout(shared, row_major) uniform; // default is now shared and row_major

layout(std140) uniform Transform2 { // layout of this block is std140
    mat4 M1;                       // row_major
    layout(column_major) mat4 M2;  // column major
    mat3 N1;                       // row_major
};

layout(column_major) uniform T3 {  // shared and column_major
    mat4 M13;                      // column_major
    layout(row_major) mat4 m14;    // row major
    mat3 N12;                      // column_major
};

// in one compilation unit...
layout(binding=3) uniform sampler2D s17; // s bound to unit 3

// in another compilation unit...
uniform sampler2D s17;                   // okay, s still bound at 3

// in another compilation unit...
//layout(binding=4) uniform sampler2D s; // ERROR: contradictory bindings

layout (binding = 2, offset = 4) uniform atomic_uint a2;

layout (binding = 2) uniform atomic_uint bar;

layout (binding = 2, offset = 4) uniform atomic_uint;

layout (binding = 2) uniform atomic_uint bar; // offset is 4
layout (offset = 8) uniform atomic_uint bar23;  // error, no default binding

layout (binding=3, offset=4) uniform atomic_uint a2; // offset = 4
layout (binding=2) uniform atomic_uint b2;           // offset = 0
layout (binding=3) uniform atomic_uint c2;           // offset = 8
layout (binding=2) uniform atomic_uint d2;           // offset = 4

//layout (offset=4)                // error, must include binding
//layout (binding=1, offset=0)  a; // okay
//layout (binding=2, offset=0)  b; // okay
//layout (binding=1, offset=0)  c; // error, offsets must not be shared
//                                 //        between a and c
//layout (binding=1, offset=2)  d; // error, overlaps offset 0 of a

flat  in vec4 gl_FrontColor;  // input to geometry shader, no �gl_in[]�
flat out vec4 gl_FrontColor;  // output from geometry shader

invariant gl_Position;   // make existing gl_Position be invariant

out vec3 ColorInv;
invariant ColorIvn;      // make existing Color be invariant

invariant centroid out vec3 Color4;
precise out vec4 position;

out vec3 Color5;
precise Color5;            // make existing Color be precise
in vec4 a, b, c, d;
precise out vec4 v;

coherent buffer Block {
    readonly vec4 member1;
    vec4 member2;
};

buffer Block2a {
    coherent readonly vec4 member1A;
    coherent vec4 member2A;
};

shared vec4 shv;

vec4 funcA(restrict image2D a)   {  }

vec4 funcB(image2D a)            {  }
layout(rgba32f) uniform image2D img1;
layout(rgba32f) coherent uniform image2D img2;

float func(float e, float f, float g, float h)
{
    return (e*f) + (g*h);            // no constraint on order or 
                                     // operator consistency
}

float func2(float e, float f, float g, float h)
{
    precise float result = (e*f) + (g*h);  // ensures same precision for
                                           // the two multiplies
    return result;
}

float func3(float i, float j, precise out float k)
{
    k = i * i + j;                   // precise, due to <k> declaration
}

void main()
{
    vec3 r = vec3(a * b);           // precise, used to compute v.xyz
    vec3 s = vec3(c * d);           // precise, used to compute v.xyz
    v.xyz = r + s;                          // precise                      
    v.w = (a.w * b.w) + (c.w * d.w);        // precise
    v.x = func(a.x, b.x, c.x, d.x);         // values computed in func()
                                            // are NOT precise
    v.x = func2(a.x, b.x, c.x, d.x);        // precise!
    func3(a.x * b.x, c.x * d.x, v.x);       // precise!
        
    funcA(img1);              // OK, adding "restrict" is allowed
    funcB(img2);              // illegal, stripping "coherent" is not

    {
        struct light {
            float intensity;
            vec3 position;
        };

        light lightVar = light(3.0, vec3(1.0, 2.0, 3.0));
    }
    {
        const float c[3] = float[3](5.0, 7.2, 1.1);
        const float d[3] = float[](5.0, 7.2, 1.1);

        float g;
        float a[5] = float[5](g, 1, g, 2.3, g);
        float b[3];

        b = float[3](g, g + 1.0, g + 2.0);
    }
    {
        vec4 b[2] = { vec4(1.0), vec4(1.0) };
        vec4[3][2](b, b, b);        // constructor
        vec4[][2](b, b, b);         // constructor, valid, size deduced
        vec4[3][](b, b, b);         // compile-time error, invalid type constructed
    }
}

// From shader generation in material system
mat2 transpose(mat2 _mtx)
{
	vec2 v0 = _mtx[0];
	vec2 v1 = _mtx[1];

	return mat2(
		  vec2(v0.x, v1.x)
		, vec2(v0.y, v1.y)
		);
}

mat3 transpose(mat3 _mtx)
{
	vec3 v0 = _mtx[0];
	vec3 v1 = _mtx[1];
	vec3 v2 = _mtx[2];

	return mat3(
		  vec3(v0.x, v1.x, v2.x)
		, vec3(v0.y, v1.y, v2.y)
		, vec3(v0.z, v1.z, v2.z)
		);
}

mat4 transpose(mat4 _mtx)
{
	vec4 v0 = _mtx[0];
	vec4 v1 = _mtx[1];
	vec4 v2 = _mtx[2];
	vec4 v3 = _mtx[3];

	return mat4(
		  vec4(v0.x, v1.x, v2.x, v3.x)
		, vec4(v0.y, v1.y, v2.y, v3.y)
		, vec4(v0.z, v1.z, v2.z, v3.z)
		, vec4(v0.w, v1.w, v2.w, v3.w)
		);
}
#define ivec2 vec2
#define ivec3 vec3
#define ivec4 vec4
// shaderc command line:
attribute vec4 a_color0;
attribute vec4 a_normal;
attribute vec3 a_position;
attribute vec4 a_tangent;
attribute vec2 a_texcoord0;
varying highp vec3 v_bitangent;
varying highp noperspective vec4 v_color0;
varying mediump centroid vec3 v_normal;
varying vec3 v_tangent;
varying vec2 v_texcoord0;
varying vec3 v_viewDir;
varying vec3 v_wpos;
vec3 instMul(vec3 _vec, mat3 _mtx) { return ( (_vec) * (_mtx) ); }
vec3 instMul(mat3 _mtx, vec3 _vec) { return ( (_mtx) * (_vec) ); }
vec4 instMul(vec4 _vec, mat4 _mtx) { return ( (_vec) * (_mtx) ); }
vec4 instMul(mat4 _mtx, vec4 _vec) { return ( (_mtx) * (_vec) ); }
float rcp(float _a) { return 1.0/_a; }
vec2 rcp(vec2 _a) { return vec2(1.0)/_a; }
vec3 rcp(vec3 _a) { return vec3(1.0)/_a; }
vec4 rcp(vec4 _a) { return vec4(1.0)/_a; }
vec2 vec2_splat(float _x) { return vec2(_x, _x); }
vec3 vec3_splat(float _x) { return vec3(_x, _x, _x); }
vec4 vec4_splat(float _x) { return vec4(_x, _x, _x, _x); }
mat4 mtxFromRows(vec4 _0, vec4 _1, vec4 _2, vec4 _3)
{
return mat4(_0, _1, _2, _3);
}
mat4 mtxFromCols(vec4 _0, vec4 _1, vec4 _2, vec4 _3)
{
return transpose(mat4(_0, _1, _2, _3) );
}
uniform vec4 u_viewRect;
uniform vec4 u_viewTexel;
uniform mat4 u_view;
uniform mat4 u_invView;
uniform mat4 u_proj;
uniform mat4 u_invProj;
uniform mat4 u_viewProj;
uniform mat4 u_invViewProj;
uniform mat4 u_model[32];
uniform mat4 u_modelView;
uniform mat4 u_modelViewProj;
uniform vec4 u_alphaRef4;
vec4 ViewRect;
mat4 Proj;
mat4 WorldArray[32];
mat4 View;
vec4 ViewTexel;
mat4 InvView;
mat4 InvProj;
mat4 ViewProj;
mat4 InvViewProj;
mat4 World;
uniform vec4 LightDirectionAndIntensity;
mat4 WorldView;
mat4 WorldViewProj;
float AlphaRef;
uniform vec4 MatColor;
struct VertexInput {
vec4 tangent;
vec4 normal;
vec3 position;
vec4 color0;
vec2 texcoord0;
};
struct VertexOutput {
vec4 position;
vec2 texcoord0;
vec3 wpos;
vec3 viewDir;
vec3 normal;
vec3 tangent;
vec3 bitangent;
vec4 color0;
};
struct FragmentInput {
vec2 texcoord0;
vec3 wpos;
vec3 viewDir;
vec3 normal;
vec3 tangent;
vec3 bitangent;
vec4 color0;
};
struct FragmentOutput {
vec4 Color0;
vec4 Color1;
vec4 Color2;
vec4 Color3;
};
uniform sampler2D s_Metal;
uniform sampler2D s_MatTexture;
void VertShared(VertexInput vertInput, inout VertexOutput vertOutput) {
vec3 wpos = ( (World) * (vec4(vertInput.position, 1.0)) ).xyz;
vertOutput.position = ( (ViewProj) * (vec4(wpos, 1.0)) );
vec3 normal = vertInput.normal.xyz;
vec3 wnormal = ( (World) * (vec4(normal.xyz, 0.0)) ).xyz;
vec3 tangent = vertInput.tangent.xyz;
vec3 wtangent = ( (World) * (vec4(tangent.xyz, 0.0)) ).xyz;
vec3 viewNormal = normalize(( (View) * (vec4(wnormal, 0.0)) ).xyz);
vec3 viewTangent = normalize(( (View) * (vec4(wtangent, 0.0)) ).xyz);
vec3 viewBitangent = cross(viewNormal, viewTangent);
mat3 tbn = mat3(viewTangent, viewBitangent, viewNormal);
vertOutput.wpos = wpos.xyz;
vec3 view = ( (View) * (vec4(wpos, 0.0)) ).xyz;
vertOutput.viewDir = ( (view) * (tbn) );
vertOutput.normal = viewNormal;
vertOutput.tangent = viewTangent;
vertOutput.bitangent = viewBitangent;
vertOutput.texcoord0 = vertInput.texcoord0;
vertOutput.color0 = vertInput.color0;
}
void Vert(VertexInput vertInput, inout VertexOutput vertOutput) {
VertShared(vertInput, vertOutput);
}
void Frag(FragmentInput fragInput, inout FragmentOutput fragOutput) {
mat3 tbn = mat3(
normalize(fragInput.tangent),
normalize(fragInput.bitangent),
normalize(fragInput.normal)
);
mat3 vsToTs = transpose(tbn);
vec3 normal;
normal.xyz = vec3(0,0,1);
vec3 vsLightDir = ( (View) * (vec4(LightDirectionAndIntensity.xyz, 0)) ).xyz;
vec3 lightDir = normalize(vsLightDir.xyz);
float l = clamp(dot(lightDir, fragInput.normal), 0.0, 1.0);
vec4 lightColor = vec4(.2, .2, .2, .2) + .8 * vec4(l, l, l, 1);
vec4 diffuse = MatColor;
diffuse *= texture2D(s_MatTexture, fragInput.texcoord0);
diffuse *= fragInput.color0;
fragOutput.Color0 = diffuse;
}
void main(){
VertexInput vertexInput;
VertexOutput vertexOutput;
vertexInput.tangent = a_tangent;
vertexInput.normal = a_normal;
vertexInput.position = a_position;
vertexInput.color0 = a_color0;
vertexInput.texcoord0 = a_texcoord0;
vertexOutput.texcoord0 = vec2(0,0);
vertexOutput.wpos = vec3(0,0,0);
vertexOutput.viewDir = vec3(0,0,0);
vertexOutput.normal = vec3(0,0,0);
vertexOutput.tangent = vec3(0,0,0);
vertexOutput.bitangent = vec3(0,0,0);
vertexOutput.color0 = vec4(0,0,0,0);
vertexOutput.position = vec4(0,0,0,0);
ViewRect = u_viewRect;
Proj = u_proj;
{
for(int initId = 0; initId < 32; initId++) {
WorldArray[initId] = u_model[initId];
}
}
View = u_view;
ViewTexel = u_viewTexel;
InvView = u_invView;
InvProj = u_invProj;
ViewProj = u_viewProj;
InvViewProj = u_invViewProj;
World = u_model[0];
WorldView = u_modelView;
WorldViewProj = u_modelViewProj;
AlphaRef = u_alphaRef4.x;
Vert(vertexInput, vertexOutput);
v_texcoord0 = vertexOutput.texcoord0;
v_wpos = vertexOutput.wpos;
v_viewDir = vertexOutput.viewDir;
v_normal = vertexOutput.normal;
v_tangent = vertexOutput.tangent;
v_bitangent = vertexOutput.bitangent;
v_color0 = vertexOutput.color0;
gl_Position = vertexOutput.position;
}


uniform sampler2D tex;
varying vec2 coord;

void main (void)
{
    vec4 v = texture2D(tex, coord);

    if (v == vec4(0.1,0.2,0.3,0.4))
        discard;

    int a;
    if(true) {
        a = 1;
    } else if(v == false) {
        a = 2;
    }
    else if(v == 0)
        a = 4;
    else {
        a = 5;
    }

    if(!a) {
        a = a;
    }

    gl_FragColor = v;
}


void main()
{
    switch(int(in0.w)) {
    case 0: FragColor = vec4(in0.x + 0); break;
    case 1: FragColor = vec4(in0.y + 1); break;
    case 2: FragColor = vec4(in0.z + 2); break;
    default: FragColor = vec4(-1);
    }
}

#version 310 es
precision mediump float;
flat in int c, d;
in float x;
out float color;
in vec4 v;

vec4 foo1(vec4 v1, vec4 v2, int i1)
{
    switch (i1)
    {
    case 0:
        return v1;
    case 2:
    case 1:
        return v2;
    case 3:
        return v1 * v2;
    }

    return vec4(0.0);
}

vec4 foo2(vec4 v1, vec4 v2, int i1)
{
    switch (i1)
    {
    case 0:
        return v1;
    case 2:
        return vec4(1.0);
    case 1:
        return v2;
    case 3:
        return v1 * v2;
    }

    return vec4(0.0);
}

void main()
{
    float f;
    int a[2];
    int local = c;

    switch(++local)
    {
    }

    switch (c) {
    case 1:
        f = sin(x);
        break;
    case 2:
        f = cos(x);
        break;
    default:
        f = tan(x);
    }

    switch (c) {
    case 1:
        f += sin(x);
    case 2:
        f += cos(x);
        break;
    default:
        f += tan(x);
    }

    switch (c) {
    case 1:
        f += sin(x);
        break;
    case 2:
        f += cos(x);
        break;
    }

    switch (c) {
    case 1:
        f += sin(x);
        break;
    case 2:
        switch (d) {
        case 1:
            f += x * x * x;
            break;
        case 2:
            f += x * x;
            break;
        }
        break;
    default:
        f += tan(x);
    }

    for (int i = 0; i < 10; ++i) {
        switch (c) {
        case 1:
            f += sin(x);
            for (int j = 20; j < 30; ++j) {
                ++f;
                if (f < 100.2)
                    break;
            }
            break;
        case 2:
            f += cos(x);
            break;
            break;
        default:
            f += tan(x);
        }

        if (f < 3.43)
            break;
    }

    switch (c) {
    case 1:
        f += sin(x);
        break;
    case 2:
        // test no statements at end
    }

    color = f + float(local);

    color += foo1(v,v,c).y;
    color += foo2(v,v,c).z;

    switch (c) {
    case 0: break;
    default:
    }

    switch (c) {
    default:
    }
}