#ifndef LIBIRARY_MY_CONVOLUTION
#define LIBIRARY_MY_CONVOLUTION

#include "UnityCG.cginc"

fixed toGray(fixed4 c) {
    return c.b*0.114 +c.g*0.587 + c.r*0.299;
}
/**
计算高斯模糊点的权重
**/
fixed gaussianNxN(fixed sd, fixed i, fixed j) {
    return (1/(sd*sd*UNITY_TWO_PI))*exp(-(i*i+j*j)/(2*sd*sd));
}

fixed gaussian(fixed3 input[3]) {
    fixed3 GaussianMatrix[3];
    GaussianMatrix[0] = fixed3(0.0947416, 0.118318, 0.0947416);
    GaussianMatrix[1] = fixed3(0.118318, 0.147761, 0.118318);
    GaussianMatrix[2] = fixed3(0.0947416, 0.118318, 0.0947416);
    return dot(input[0],GaussianMatrix[0]) + dot(input[1],GaussianMatrix[1]) + dot(input[2],GaussianMatrix[2]);
}
/**
计算梯度和角度
**/
fixed2 sobel(fixed3 input[3]) {
    fixed3 xsobel[3];
    xsobel[0] = fixed3(-1, 0, 1);
    xsobel[1] = fixed3(-2, 0, 2);
    xsobel[2] = fixed3(-1, 0, 1);
    fixed3 ysobel[3];
    ysobel[0] = fixed3(-1,-2,-1);
    ysobel[1] = fixed3(0, 0, 0);
    ysobel[2] = fixed3(1, 2, 1);
    fixed gx = dot(input[0],xsobel[0]) + dot(input[1],xsobel[1]) + dot(input[2],xsobel[2]);
    fixed gy = dot(input[0],ysobel[0]) + dot(input[1],ysobel[1]) + dot(input[2],ysobel[2]);
    fixed g = abs(gx) + abs(gy);
    fixed a = UNITY_PI/2 - atan2(gy,gx);
    a = a < 0 ? UNITY_TWO_PI + a : a;
    return fixed2(g,a/UNITY_TWO_PI);
}
#endif