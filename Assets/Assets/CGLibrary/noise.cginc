#ifndef MY_LIBRARY_NOISE
#define MY_LIBRARY_NOISE

#include "hash.cginc"

float fade(float t) {
    return t*t*t*( t*( 6*t - 15 ) + 10 );
}

float2 fade(float2 t) {
    return float2(fade(t.x), fade(t.y));
}

float3 fade(float3 t) {
    return float3(fade(t.x),fade(t.y),fade(t.z));
}

float4 fade(float4 t) {
    return float4(fade(t.x),fade(t.y),fade(t.z),fade(t.w));
}

float perlinNoise2(float2 p) {
    float2 f = fract(p);
    float2 i = floor(p);
    float2 w = fade(f);

    float2 v1 = float2(0.,0.);
    float2 v2 = float2(0.,1.);
    float2 v3 = float2(1.,0.);
    float2 v4 = float2(1.,1.);
    return lerp(
        lerp( dot(hash22(v1+i),f-v1) , dot(hash22(v3+i),f-v3), w.x ),
        lerp( dot(hash22(v2+i),f-v2) , dot(hash22(v4+i),f-v4), w.x ),
        w.y
    );
}

float valueNoise2(float2 p) {
    float2 f = fract(p);
    float2 i = floor(p);
    float2 w = fade(f);

    float2 v1 = float2(0.,0.);
    float2 v2 = float2(0.,1.);
    float2 v3 = float2(1.,0.);
    float2 v4 = float2(1.,1.);

    return lerp(
        lerp( hash12(v1+i), hash12(v3+i), w.x ),
        lerp( hash12(v2+i), hash12(v4+i), w.x ),
        w.y
    );
}

float simplexK1(float n) {
    return (sqrt(n+1) - 1) / n;
}

float simplexK2(float n) {
    return ((1./(sqrt(n+1))) - 1) / n;
}

float2 simplexTransform(float2 p, float k) {
    float delta = (p.x+p.y) * k;
    return float2( p.x + delta, p.y + delta );
}

float simplexNoise2(float2 p) {
    float k1 = simplexK1(2.);
    float k2 = simplexK2(2.);

    float2 pt = simplexTransform(p, k1);

    float2 i = floor(pt);

    float2 v1 = float2(0.,0.);
    float2 v2 = float2(0.,1.);
    float2 v3 = float2(1.,0.);
    float2 v4 = float2(1.,1.);

    float2 pf = p - simplexTransform(i, k2);
    float2 mid = pf.x > pf.y ? v3 : v2;
    float2 a = pf - simplexTransform(v1, k2);
    float2 b = pf - simplexTransform(mid, k2);
    float2 c = pf - simplexTransform(v4, k2);

    // (r^2 - dist^2)^4 * dot(dist, grad); 
    float3 h = max(0.5 - float3(dot(a,a), dot(b,b), dot(c,c)), 0.);//r^2 - dist^2
    //r^2取0.5时上述公式最大值大约在1/70，乘70可放缩到0~1区间
    return dot(h*h*h*h*float3(
            dot(a,hash22(i+v1)), 
            dot(b,hash22(i+mid)),
            dot(c,hash22(i+v4))
            ), 
            float3(70.0,70.0,70.0));
}


#endif