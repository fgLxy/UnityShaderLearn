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

fixed raycastLine(fixed2 p1, fixed p2, fixed2 origin, fixed angle) {
    fixed2 dir = p1 - p2;
    fixed t = dir.y/dir.x;
    fixed o = p1.y - t*p1.x;

    fixed t1 = 1/tan(angle);
    fixed o1 = origin.y - t1*origin.x;

    fixed x = (o1 - o)/(t-t1);
    fixed y = t1*x + o1;
    return length(fixed2(x,y));
}


fixed raycastNCorner(int n, fixed2 rayDir, fixed oR, fixed iR) {
    fixed averageAngle = UNITY_TWO_PI / n;
    fixed a = angle(rayDir);
    int multi = a / averageAngle;
    a -= multi*averageAngle;
    fixed2 p1 = fixed2(0,oR);
    fixed2 p2 = fixed2(sin(averageAngle/2),cos(averageAngle/2))*iR;
    if (a > averageAngle/2) {
        a = averageAngle - a;
        return raycastLine(p1,p2,fixed2(0.,0.), a);
    }
    else {
        return raycastLine(p1,p2,fixed2(0.,0.), a);
    }
}

#endif