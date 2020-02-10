#ifndef MY_LIBRARY_SHAPE
#define MY_LIBRARY_SHAPE

#include "UnityCG.cginc"


fixed angle(fixed2 rayDir) {
    fixed2 origin = normalize(fixed2(0., 1.));
    fixed a = acos(dot(normalize(rayDir), origin));
    return rayDir.x < 0 ? UNITY_TWO_PI - a : a;
}

/**
检查射线方向(射线从中心点发出)到多边形边界的距离。默认半径为1,需要则自己放缩
**/
fixed raycastNPolygon(int n, fixed2 rayDir) {
    fixed averageAngle = UNITY_TWO_PI / n;
    fixed2 origin = normalize(fixed2(0., 1.));
    fixed a = angle(rayDir);
    int multi = a / averageAngle;
    a -= multi*averageAngle;
    if (a < averageAngle/2) {
        return abs(1. / cos(a));
    }
    else {
        return abs(1. / cos(averageAngle - a));
    }
}

#endif