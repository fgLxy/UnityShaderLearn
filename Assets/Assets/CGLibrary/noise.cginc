#ifndef MY_LIBRARY_NOISE
#define MY_LIBRARY_NOISE

#include "hash.cginc"

#define PI 3.14159265359f

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
    return p + delta;
}

float4 simplexTransform(float4 p, float k) {
    float delta = (p.x+p.y+p.z+p.w) * k;
    return p + delta;
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

float simplexNoise4(float4 p) {
    float k1 = simplexK1(4);
    float k2 = simplexK2(4);
    //p坐标转换到转换空间中
    float4 pt = simplexTransform(p, k1);

    //转换空间中的索引向量，指明在哪个网格中
    float4 pti = floor(pt);
    //将转换空间中的网格内偏移向量转换到原空间
    float4 pf = p - simplexTransform(pti, k2);
    float singleArr[] = {pf.x,pf.y,pf.z,pf.w};
    int sortIdx[4] = {1,2,3,4};
    //排序确定各个维度大小关系。方便后续判断单行的边
    for (int i = 0; i < 3; i++) {
        for (int j = i + 1; j < 4; j++) {
            if (singleArr[i] < singleArr[j]) {
                float tmp = singleArr[i];
                singleArr[i] = singleArr[j];
                singleArr[j] = tmp;
                int tmpIdx = sortIdx[i];
                sortIdx[i] = sortIdx[j];
                sortIdx[j] = tmpIdx;
            }
        }
    }
    //起始顶点。坐标为转换空间中的坐标
    float4 o = float4(0.,0.,0.,0.);
    float4 cur = float4(o);
    //转换空间的单形顶点
    float4 vertexArr[5];
    vertexArr[0] = float4(o);
    vertexArr[4] = float4(1.,1.,1.,1.);
    //找出当前点所在单形的所有组成顶点
    for (int i = 0; i < 3; i++) {
        if (sortIdx[i] == 1) {
            cur += float4(1,0,0,0);
        }
        else if (sortIdx[i] == 2) {
            cur += float4(0,1,0,0);
        }
        else if (sortIdx[i] == 3) {
            cur += float4(0,0,1,0);
        }
        else {
            cur += float4(0,0,0,1);
        }
        vertexArr[i + 1] = float4(cur);
    }
    
    //计算h
    float hArr[5];
    float4 dist[5];
    for (int i = 0; i < 5; i++) {
        //网格内偏移到顶点的距离向量，转换回源空间
        dist[i] = pf - simplexTransform(vertexArr[i], k2);
        //计算该顶点距离的h分量
        hArr[i] = max(0.6 - dot(dist[i],dist[i]), 0.);
    }
    float result = 0.;
    // (r^2 - dist^2)^4 * dot(dist, grad); 
    for (int i = 0; i < 5; i++) {
        //转换空间索引坐标+网格顶点坐标，可以计算出真正的转换空间网格顶点坐标,以此获取梯度向量
        result += hArr[i]*hArr[i]*hArr[i]*hArr[i]*dot(dist[i], hash44(pti+vertexArr[i]));
    }
    return result*27;
}

float simplexfbm4d1(float4 p) {
    float noise = 0;
    float4 pos = p;
    float w = 1.;
    for (int i = 0; i < 5; i++) {
        noise += w*simplexNoise4(pos);
        w /= 2;
        pos *= 2;
    }
    return noise;
}

float simplexfbm4d2(float4 p) {
    float noise = 0;
    float4 pos = p;
    float w = 1.;
    for (int i = 0; i < 5; i++) {
        noise += w*abs(simplexNoise4(pos));
        w /= 2;
        pos *= 2;
    }
    return noise;
}

float simplexfbm4d3(float4 p) {
    float noise = 0;
    float4 pos = p;
    float w = 1.;
    for (int i = 0; i < 5; i++) {
        noise += w*abs(simplexNoise4(pos));
        w /= 2;
        pos *= 2;
    }
    return sin(p.x + noise);
}


float seamlessSimplexNoise2(float2 p,float unit,int type) {
    float nx = cos(p.x*2.*PI)*unit/(2.0*PI);
    float ny = cos(p.y*2.*PI)*unit/(2.0*PI);
    float nz = sin(p.x*2.*PI)*unit/(2.0*PI);
    float nw = sin(p.y*2.*PI)*unit/(2.0*PI);
    float4 pos = float4(nx,ny,nz,nw);
    return type == 1 ? simplexNoise4(pos) :
        type == 2 ? simplexfbm4d1(pos) :
        type == 3 ? simplexfbm4d2(pos) :
        simplexfbm4d3(pos);
}

#endif